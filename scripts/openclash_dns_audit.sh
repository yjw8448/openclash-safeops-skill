#!/bin/sh
# Read-only DNS conflict audit for OpenClash/OpenWrt.
# Usage: sh openclash_dns_audit.sh

set +e

section() { echo; echo "## $1"; }
cmd() { echo "+ $*"; "$@" 2>&1 || true; }
cmd_sh() { echo "+ $*"; sh -c "$*" 2>&1 || true; }

cat <<HEADER
# OpenClash DNS Conflict Audit
Generated: $(date '+%Y-%m-%d %H:%M:%S %Z')
Read-only. No files or services will be changed.
HEADER

section "Services that may affect DNS"
for svc in dnsmasq openclash smartdns AdGuardHome mosdns homeproxy passwall shadowsocksr uhttpd; do
  if [ -x "/etc/init.d/$svc" ]; then
    echo "### $svc"
    /etc/init.d/$svc status 2>&1 || true
  fi
done

section "Port listeners: DNS and OpenClash focus"
if command -v ss >/dev/null 2>&1; then
  cmd_sh "ss -lntup 2>/dev/null | grep -E ':53 |:5353|:5335|:6053|:6553|:7874|:7890|:7891|:7892|:7893|:7895|:9090' || true"
  cmd_sh "ss -lnup 2>/dev/null | grep -E ':53 |:5353|:5335|:6053|:6553|:7874' || true"
else
  cmd_sh "netstat -lntup 2>/dev/null | grep -E ':53 |:5353|:5335|:6053|:6553|:7874|:7890|:7891|:7892|:7893|:7895|:9090' || true"
fi

section "UCI DNS-related options"
cmd_sh "uci show dhcp 2>/dev/null | grep -Ei 'dns|domain|server|port|noresolv|cachesize|rebind|address|confdir|bogus' || true"
cmd_sh "uci show openclash 2>/dev/null | sed -E 's#(https?://)[^ ]+#\1***REDACTED***#g' | grep -Ei 'dns|fake|redir|tun|ipv6|enhance|nameserver|fallback|dashboard|secret|port|proxy|enable' || true"
cmd_sh "uci show smartdns 2>/dev/null | grep -Ei 'enabled|port|server|bind|prefetch|cache|dualstack|response|speed|domain' || true"
cmd_sh "uci show AdGuardHome 2>/dev/null | grep -Ei 'enabled|port|address|dns|redirect|workdir' || true"
cmd_sh "uci show mosdns 2>/dev/null | grep -Ei 'enabled|listen|port|redirect|dns' || true"

section "Generated dnsmasq config and resolv files"
cmd_sh "ls -lah /tmp/resolv.conf* /tmp/resolv.conf.d/* /var/etc/dnsmasq.conf* /tmp/dnsmasq.d/* 2>/dev/null || true"
cmd_sh "grep -RniE 'server=|no-resolv|resolv-file|address=|conf-dir|cache-size|port=' /var/etc/dnsmasq.conf* /tmp/dnsmasq.d/* 2>/dev/null | head -200 || true"
cmd_sh "for f in /etc/resolv.conf /tmp/resolv.conf /tmp/resolv.conf.d/*; do [ -f \"$f\" ] && echo \"### $f\" && sed -n '1,80p' \"$f\"; done"

section "LAN and default route"
cmd ip -br addr
cmd ip route
cmd ip -6 route

section "DNS resolution tests"
for host in openwrt.org baidu.com github.com openai.com router.lan; do
  echo "### $host via 127.0.0.1"
  nslookup "$host" 127.0.0.1 2>&1 | head -80 || true
  echo "### $host via 223.5.5.5"
  nslookup "$host" 223.5.5.5 2>&1 | head -80 || true
done

section "Heuristic warnings"
RUNNING_DNS_SERVICES=""
for svc in smartdns AdGuardHome mosdns homeproxy passwall shadowsocksr; do
  if [ -x "/etc/init.d/$svc" ] && /etc/init.d/$svc status >/dev/null 2>&1; then
    RUNNING_DNS_SERVICES="$RUNNING_DNS_SERVICES $svc"
  fi
done
if [ -n "$RUNNING_DNS_SERVICES" ]; then
  echo "WARNING: Extra DNS/proxy plugins appear running:$RUNNING_DNS_SERVICES"
  echo "Check whether multiple plugins are hijacking or forwarding DNS at the same time."
else
  echo "No obvious extra DNS plugin service is running."
fi

if command -v ss >/dev/null 2>&1; then
  COUNT53="$(ss -lnup 2>/dev/null | grep -c ':53 ' || true)"
  [ "${COUNT53:-0}" -gt 1 ] && echo "WARNING: More than one UDP listener may be using port 53. Inspect the listener table above."
fi

cat <<'HINTS'
Hints:
- If OpenClash uses Fake-IP and another cache/filter DNS plugin is placed in front, stale cached fake IP records can cause strange failures.
- If DNS works via 223.5.5.5 but fails via 127.0.0.1, the local DNS chain is broken.
- If stopping OpenClash restores DNS, inspect OpenClash DNS mode, fake-ip-filter, dnsmasq upstream, and extra DNS plugins.
HINTS
