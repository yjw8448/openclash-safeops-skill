#!/bin/sh
# Read-only OpenClash/OpenWrt diagnosis script.
# Safe to run over SSH. It does not modify configuration.

set +e

redact() {
  sed -E "s#(https?://)[^[:space:]\"']+#\\1***REDACTED***#g; s/(password|passwd|secret|token|key)[=:][^[:space:]\"']+#\\1=***REDACTED***#Ig"
}

section() { echo; echo "## $1"; }
cmd() { echo "+ $*"; "$@" 2>&1 || true; }
cmd_redacted() { echo "+ $*"; "$@" 2>&1 | redact || true; }

cat <<HEADER
# OpenClash SafeOps Diagnosis
Generated: $(date '+%Y-%m-%d %H:%M:%S %Z')
This report is read-only. Subscription URLs and secrets are redacted where possible.
HEADER

section "System"
cmd cat /etc/openwrt_release
cmd uname -a
cmd date
cmd uptime
cmd df -h
cmd free -m
cmd ubus call system board

section "Network addresses and routes"
cmd ip -br addr
cmd ip route
cmd ip -6 route

section "Detected default gateway and LAN candidates"
ip route | awk '/default/ {print "default_gateway=" $3 " dev=" $5}' || true
ip -br addr | awk '$1 ~ /br-lan|lan/ {print}' || true

section "UCI network summary"
cmd uci show network
cmd uci show dhcp

section "Services"
for svc in openclash dnsmasq firewall uhttpd network smartdns AdGuardHome; do
  if [ -x "/etc/init.d/$svc" ]; then
    echo "### $svc"
    /etc/init.d/$svc status 2>&1 || true
  fi
done

section "OpenClash package and config"
cmd sh -c "opkg list-installed | grep -Ei 'openclash|mihomo|clash'"
cmd_redacted uci show openclash
cmd ls -lah /etc/openclash
cmd find /etc/openclash -maxdepth 3 -type f

section "OpenClash core files"
cmd find /etc/openclash -maxdepth 4 -type f | grep -Ei 'clash|mihomo|meta|core|geo|mmdb|dat|ui' | head -200

section "Processes"
cmd sh -c "ps w | grep -Ei 'openclash|clash|mihomo|smartdns|adguard|dnsmasq' | grep -v grep"

section "Ports"
if command -v ss >/dev/null 2>&1; then
  cmd ss -lntup
  cmd ss -lnup
else
  cmd netstat -lntup
  cmd netstat -lnup
fi

section "Port conflict focus"
if command -v ss >/dev/null 2>&1; then
  ss -lntup 2>/dev/null | grep -E ':53 |:80 |:443 |:7874|:7890|:7891|:7892|:7893|:7895|:9090|:6053|:6553' || true
  ss -lnup 2>/dev/null | grep -E ':53 |:7874|:6053|:6553' || true
fi

section "DNS tests"
for host in openwrt.org baidu.com github.com openai.com; do
  echo "### nslookup $host via 127.0.0.1"
  nslookup "$host" 127.0.0.1 2>&1 || true
  echo "### nslookup $host via 223.5.5.5"
  nslookup "$host" 223.5.5.5 2>&1 || true
done

section "HTTP tests"
for url in http://connectivitycheck.gstatic.com/generate_204 http://www.gstatic.com/generate_204 https://openwrt.org https://github.com; do
  echo "### curl $url"
  curl -I -L --connect-timeout 5 --max-time 12 "$url" 2>&1 | head -40 || true
done

section "Firewall backend snapshot"
if command -v nft >/dev/null 2>&1; then
  cmd sh -c "nft list ruleset | sed -n '1,260p'"
fi
if command -v iptables-save >/dev/null 2>&1; then
  cmd sh -c "iptables-save | sed -n '1,260p'"
fi

section "OpenClash logs"
[ -f /tmp/openclash.log ] && tail -n 260 /tmp/openclash.log | redact || echo "No /tmp/openclash.log"
[ -f /etc/openclash/openclash.log ] && tail -n 260 /etc/openclash/openclash.log | redact || true
logread | grep -Ei 'openclash|clash|mihomo|dnsmasq|firewall|smartdns|uhttpd' | tail -n 260 | redact || true

section "YAML parse and group check"
YAML_FILES="$(find /etc/openclash -maxdepth 3 -type f \( -name '*.yaml' -o -name '*.yml' \) 2>/dev/null | tr '\n' ' ')"
if [ -n "$YAML_FILES" ]; then
  echo "candidates: $YAML_FILES"
  FIRST="$(echo "$YAML_FILES" | awk '{print $1}')"
  echo "first_candidate=$FIRST"
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$FIRST" <<'PY' 2>&1 || true
import sys, re
p=sys.argv[1]
try:
    import yaml
except Exception as e:
    print('Python yaml module missing:', e)
    sys.exit(0)
try:
    with open(p, 'r', encoding='utf-8') as f:
        data=yaml.safe_load(f)
    print('YAML OK:', p)
    if isinstance(data, dict):
        groups=[]
        for g in data.get('proxy-groups') or []:
            if isinstance(g, dict) and 'name' in g:
                groups.append(str(g['name']))
        print('proxy_group_count=', len(groups))
        print('proxy_groups=', ', '.join(groups[:80]))
        refs=[]
        for r in data.get('rules') or []:
            if isinstance(r, str):
                parts=r.split(',')
                if len(parts)>=3:
                    refs.append(parts[-1])
        missing=sorted({x for x in refs if x not in groups and x not in ('DIRECT','REJECT','REJECT-DROP','PASS') and not x.startswith('no-resolve')})
        print('possible_missing_rule_targets=', ', '.join(missing[:80]) if missing else 'none')
except Exception as e:
    print('YAML CHECK ERROR:', type(e).__name__, str(e))
PY
  elif command -v ruby >/dev/null 2>&1; then
    ruby -e 'require "yaml"; YAML.load_file(ARGV[0]); puts "YAML OK"' "$FIRST" 2>&1 || true
  else
    echo "No ruby/python3 YAML parser found. Skipping parse check."
  fi
else
  echo "No YAML candidate found under /etc/openclash."
fi

section "Diagnosis hints"
cat <<'HINTS'
- If DNS tests fail only while OpenClash is running, suspect DNS hijack/Fake-IP/SmartDNS conflict.
- If YAML check reports missing rule targets, rules reference strategy groups that do not exist.
- If LuCI is down but SSH works, restart uhttpd only; do not restart network.
- If OpenClash stopped and dnsmasq restarted restores internet, OpenClash config/DNS/firewall integration is the likely cause.
HINTS
