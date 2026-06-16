#!/bin/sh
# Quarantine/backup an unbound or suspicious OpenClash YAML without deleting it.
# Dry-run by default. It only copies files to /root and never changes network/dhcp/firewall.

set -eu
CONFIG_FILE="${1:-}"
APPLY=0
[ "${2:-}" = "--apply" ] && APPLY=1

if [ -z "$CONFIG_FILE" ] || [ ! -f "$CONFIG_FILE" ]; then
  echo "Usage: sh openclash_quarantine_unbound_config.sh /etc/openclash/config/config-a.yaml [--apply]"
  exit 2
fi

case "$CONFIG_FILE" in
  /etc/openclash/*) ;;
  *) echo "REFUSE: config file must be under /etc/openclash"; exit 3 ;;
esac

TS="$(date +%Y%m%d-%H%M%S)"
QDIR="/root/openclash-unbound-config-quarantine-$TS"

printf '%s\n' "===== Quarantine unbound OpenClash config ====="
echo "CONFIG_FILE=$CONFIG_FILE"
echo "APPLY=$APPLY"
echo "QUARANTINE_DIR=$QDIR"
echo "This script copies the suspicious file and OpenClash state. It does not delete or modify the original YAML."

echo "file_summary:"
ls -lh "$CONFIG_FILE" 2>/dev/null || true
cksum "$CONFIG_FILE" 2>/dev/null || true
grep -E '^(proxies:|proxy-groups:|rules:|proxy-providers:|rule-providers:|dns:)' "$CONFIG_FILE" 2>/dev/null | head -30 || true

if [ "$APPLY" = "0" ]; then
  echo "DRY-RUN only. Re-run with --apply to copy into quarantine dir."
  exit 0
fi

mkdir -p "$QDIR"
cp -a "$CONFIG_FILE" "$QDIR/" 2>/dev/null || true
cp -a /etc/config/openclash "$QDIR/openclash.uci" 2>/dev/null || true
cp -a /etc/openclash "$QDIR/openclash-dir" 2>/dev/null || true
find /etc/openclash/config -maxdepth 1 -type f \( -name '*.yaml' -o -name '*.yml' \) -exec cksum {} \; 2>/dev/null > "$QDIR/config-fingerprints.txt" || true
uci show openclash 2>/dev/null | sed -E 's#https?://[^ ]+#<SUB_URL_REDACTED>#g; s#(secret|password|passwd|token|key)=.*#\1=<REDACTED>#Ig' > "$QDIR/openclash-uci-redacted.txt" || true

echo "QUARANTINE_CREATED=$QDIR"
echo "No original file was deleted. Ask user before restore/delete/rebuild."
