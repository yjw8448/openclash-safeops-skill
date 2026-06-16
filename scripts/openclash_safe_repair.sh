#!/bin/sh
# Low-risk OpenClash repair. Dry-run by default.
# Usage:
#   sh openclash_safe_repair.sh                         # dry-run
#   sh openclash_safe_repair.sh --apply                 # apply low-risk repair, leaves OpenClash stopped
#   sh openclash_safe_repair.sh --apply --start-openclash
# For medium-risk changes, start openclash_watchdog.sh first.

set -eu
APPLY=0
START_OPENCLASH=0
for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=1 ;;
    --start-openclash) START_OPENCLASH=1 ;;
    *) echo "Unknown argument: $arg"; exit 1 ;;
  esac
done

run() {
  echo "+ $*"
  if [ "$APPLY" = "1" ]; then
    "$@" 2>&1 || true
  fi
}

if [ "$APPLY" = "0" ]; then
  echo "DRY-RUN mode. Re-run with --apply to execute low-risk repair."
else
  echo "APPLY mode. Creating backup first..."
  if [ -f ./openclash_backup.sh ]; then
    sh ./openclash_backup.sh
  elif [ -f /tmp/openclash_backup.sh ]; then
    sh /tmp/openclash_backup.sh
  else
    echo "ERROR: backup script not found in current dir or /tmp."
    exit 2
  fi
fi

cat <<'PLAN'
Low-risk repair plan:
1. Stop OpenClash.
2. Kill orphaned clash/mihomo only after service stop.
3. Restart dnsmasq.
4. Restart uhttpd only if it is down.
5. Verify route/DNS/HTTP.
6. Keep OpenClash stopped unless --start-openclash is provided.
No network/dhcp/firewall UCI changes will be made.
For medium-risk changes, use openclash_watchdog.sh before applying.
PLAN

[ -x /etc/init.d/openclash ] && run /etc/init.d/openclash stop || echo "OpenClash init script not found."

PIDS="$(pidof clash 2>/dev/null || true) $(pidof mihomo 2>/dev/null || true)"
if [ -n "$(echo "$PIDS" | tr -d ' ')" ]; then
  for p in $PIDS; do run kill "$p"; done
else
  echo "No orphaned clash/mihomo process detected."
fi

[ -x /etc/init.d/dnsmasq ] && run /etc/init.d/dnsmasq restart || echo "dnsmasq init script not found."

if [ -x /etc/init.d/uhttpd ]; then
  if /etc/init.d/uhttpd status >/dev/null 2>&1; then
    echo "uhttpd is running."
  else
    run /etc/init.d/uhttpd restart
  fi
fi

echo "# Verification"
for c in \
  "ip route" \
  "nslookup openwrt.org 127.0.0.1" \
  "nslookup baidu.com 127.0.0.1" \
  "curl -I -L --connect-timeout 5 --max-time 12 https://openwrt.org"; do
  echo "+ $c"
  if [ "$APPLY" = "1" ]; then sh -c "$c" 2>&1 | head -80 || true; fi
done

if [ "$START_OPENCLASH" = "1" ]; then
  [ -x /etc/init.d/openclash ] && run /etc/init.d/openclash start || true
  if [ "$APPLY" = "1" ]; then
    sleep 8
    tail -n 160 /tmp/openclash.log 2>/dev/null || true
    nslookup github.com 127.0.0.1 2>&1 | head -80 || true
  fi
else
  echo "OpenClash is left stopped. Start manually after checking DNS/logs:"
  echo "  /etc/init.d/openclash start"
fi
