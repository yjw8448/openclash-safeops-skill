#!/bin/sh
# Read-only connectivity verification.
# Optional env:
#   OC_API=http://127.0.0.1:9090
#   OC_SECRET=your_dashboard_secret
#   PROXY=http://127.0.0.1:7890

set +e
section() { echo; echo "## $1"; }
cmd_sh() { echo "+ $*"; sh -c "$*" 2>&1 | head -120 || true; }

cat <<HEADER
# OpenClash SafeOps Connectivity Verify
Generated: $(date '+%Y-%m-%d %H:%M:%S %Z')
Read-only.
HEADER

section "Route and addresses"
cmd_sh "ip -br addr"
cmd_sh "ip route"
cmd_sh "ip -6 route"

section "Services"
for svc in openclash dnsmasq uhttpd firewall smartdns AdGuardHome mosdns; do
  [ -x "/etc/init.d/$svc" ] && { echo "### $svc"; /etc/init.d/$svc status 2>&1 || true; }
done

section "DNS"
for host in openwrt.org baidu.com github.com openai.com chatgpt.com; do
  cmd_sh "nslookup $host 127.0.0.1"
done

section "HTTP from router"
for url in http://connectivitycheck.gstatic.com/generate_204 http://www.gstatic.com/generate_204 https://openwrt.org https://github.com; do
  cmd_sh "curl -I -L --connect-timeout 5 --max-time 12 '$url'"
done

section "OpenClash proxy port test"
PROXY="${PROXY:-http://127.0.0.1:7890}"
cmd_sh "curl -I -L --proxy '$PROXY' --connect-timeout 5 --max-time 15 https://github.com"
cmd_sh "curl -I -L --proxy '$PROXY' --connect-timeout 5 --max-time 15 https://chatgpt.com"

section "Dashboard/API"
OC_API="${OC_API:-http://127.0.0.1:9090}"
AUTH=""
[ -n "${OC_SECRET:-}" ] && AUTH="Authorization: Bearer ${OC_SECRET}"
if [ -n "$AUTH" ]; then
  cmd_sh "curl -sS --connect-timeout 3 --max-time 8 -H 'Authorization: Bearer ***REDACTED***' '$OC_API/configs' >/dev/null; echo api_checked_with_secret_redacted"
  curl -sS --connect-timeout 3 --max-time 8 -H "$AUTH" "$OC_API/configs" 2>&1 | head -80 || true
else
  cmd_sh "curl -sS --connect-timeout 3 --max-time 8 '$OC_API/configs'"
fi

section "Recent logs"
cmd_sh "tail -n 160 /tmp/openclash.log 2>/dev/null"
cmd_sh "logread | grep -Ei 'openclash|clash|mihomo|dnsmasq|uhttpd|smartdns|adguard|mosdns' | tail -160"
