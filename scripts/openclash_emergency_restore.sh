#!/bin/sh
# Emergency OpenClash restore for when OpenClash breaks DNS/internet/LuCI but SSH still works.
# Dry-run by default.
# Usage:
#   sh openclash_emergency_restore.sh
#   sh openclash_emergency_restore.sh --apply
#
# This script does NOT change network/dhcp/firewall and does NOT restart network.

set -eu
APPLY=0
for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=1 ;;
    --help|-h)
      sed -n '1,40p' "$0"
      exit 0
      ;;
    *) echo "Unknown argument: $arg"; exit 1 ;;
  esac
done

run() {
  echo "+ $*"
  if [ "$APPLY" = "1" ]; then
    "$@" 2>&1 || true
  fi
}

run_sh() {
  echo "+ $*"
  if [ "$APPLY" = "1" ]; then
    sh -c "$*" 2>&1 || true
  fi
}

cat <<'PLAN'
# OpenClash SafeOps emergency restore plan
Risk: low to medium.
Actions:
1. Stop OpenClash only.
2. Kill orphaned clash/mihomo processes only after stopping OpenClash.
3. Restart dnsmasq.
4. Restart uhttpd only if LuCI service appears down.
5. Verify route, DNS, HTTP, and LuCI process.
No changes to /etc/config/network, /etc/config/dhcp, /etc/config/firewall.
No /etc/init.d/network restart.
PLAN

if [ "$APPLY" = "0" ]; then
  echo "DRY-RUN mode. Re-run with --apply to execute."
fi

[ -x /etc/init.d/openclash ] && run /etc/init.d/openclash stop || echo "OpenClash init script not found."

PIDS="$(pidof clash 2>/dev/null || true) $(pidof mihomo 2>/dev/null || true) $(pidof clash_meta 2>/dev/null || true)"
if [ -n "$(echo "$PIDS" | tr -d ' ')" ]; then
  for p in $PIDS; do run kill "$p"; done
else
  echo "No orphaned clash/mihomo process detected."
fi

[ -x /etc/init.d/dnsmasq ] && run /etc/init.d/dnsmasq restart || echo "dnsmasq init script not found."

if [ -x /etc/init.d/uhttpd ]; then
  if /etc/init.d/uhttpd status >/dev/null 2>&1; then
    echo "uhttpd appears running."
  else
    run /etc/init.d/uhttpd restart
  fi
fi

cat <<'VERIFY'
# Verification commands
VERIFY
run_sh "ip route"
run_sh "nslookup openwrt.org 127.0.0.1 | head -80"
run_sh "nslookup baidu.com 127.0.0.1 | head -80"
run_sh "curl -I -L --connect-timeout 5 --max-time 12 https://openwrt.org | head -30"
run_sh "logread | grep -Ei 'openclash|dnsmasq|uhttpd' | tail -80"

cat <<'DONE'
# Emergency restore finished.
OpenClash should remain stopped until DNS audit and YAML lint pass.
Suggested next commands:
  sh openclash_dns_audit.sh
  sh openclash_verify_connectivity.sh
  python3 openclash_lint_config.py /etc/openclash/config.yaml
DONE
