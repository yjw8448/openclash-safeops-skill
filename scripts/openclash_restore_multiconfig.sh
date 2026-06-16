#!/bin/sh
# Restore OpenClash subscription/config mapping from a backup directory.
# Dry-run by default. Restores only /etc/config/openclash and /etc/openclash.

set -eu

BACKUP_DIR="${1:-}"
APPLY=0
[ "${2:-}" = "--apply" ] && APPLY=1

if [ -z "$BACKUP_DIR" ] || [ ! -d "$BACKUP_DIR" ]; then
  echo "Usage: sh openclash_restore_multiconfig.sh <backup_dir> [--apply]"
  exit 2
fi

echo "===== OpenClash multi-config restore ====="
echo "BACKUP_DIR=$BACKUP_DIR"
echo "APPLY=$APPLY"

echo "This script restores only:"
echo "  /etc/config/openclash"
echo "  /etc/openclash/"
echo "It will NOT restore network/dhcp/firewall."

SRC_UCI=""
SRC_DIR=""
[ -f "$BACKUP_DIR/etc/config/openclash" ] && SRC_UCI="$BACKUP_DIR/etc/config/openclash"
[ -d "$BACKUP_DIR/etc/openclash" ] && SRC_DIR="$BACKUP_DIR/etc/openclash"
[ -f "$BACKUP_DIR/openclash.uci" ] && SRC_UCI="$BACKUP_DIR/openclash.uci"
[ -d "$BACKUP_DIR/openclash-dir" ] && SRC_DIR="$BACKUP_DIR/openclash-dir"

if [ -z "$SRC_UCI" ] && [ -z "$SRC_DIR" ]; then
  echo "ERROR: Backup does not contain OpenClash UCI/config directory in a known layout."
  find "$BACKUP_DIR" -maxdepth 4 -type f 2>/dev/null | sort | head -100
  exit 1
fi

echo "Source UCI: ${SRC_UCI:-not-found}"
echo "Source dir: ${SRC_DIR:-not-found}"

echo
echo "Candidate files in backup:"
find "$BACKUP_DIR" -maxdepth 4 -type f \( -name '*.yaml' -o -name '*.yml' -o -name 'openclash' -o -name 'openclash.uci' \) 2>/dev/null | sort | head -200

if [ "$APPLY" = "0" ]; then
  echo
echo "DRY-RUN only. Re-run with --apply after confirming this is the correct pre-merge backup."
  exit 0
fi

TS="$(date +%Y%m%d-%H%M%S)"
SAFETY="/root/openclash-before-multiconfig-restore-$TS"
mkdir -p "$SAFETY"
cp -a /etc/config/openclash "$SAFETY/openclash.uci.current" 2>/dev/null || true
cp -a /etc/openclash "$SAFETY/openclash-dir.current" 2>/dev/null || true
echo "CURRENT_STATE_BACKUP=$SAFETY"

/etc/init.d/openclash stop 2>/dev/null || true
sleep 2

if [ -n "$SRC_UCI" ]; then
  cp -a "$SRC_UCI" /etc/config/openclash
  echo "Restored /etc/config/openclash"
fi
if [ -n "$SRC_DIR" ]; then
  rm -rf /etc/openclash.safeops-restore-tmp
  cp -a "$SRC_DIR" /etc/openclash.safeops-restore-tmp
  rm -rf /etc/openclash
  mv /etc/openclash.safeops-restore-tmp /etc/openclash
  echo "Restored /etc/openclash/"
fi

echo "Restarting dnsmasq/uhttpd only; not restarting network."
/etc/init.d/dnsmasq restart 2>/dev/null || true
/etc/init.d/uhttpd restart 2>/dev/null || true

echo "Post-restore summary:"
ls -lah /etc/openclash /etc/openclash/config 2>/dev/null || true
uci show openclash 2>/dev/null | sed -E 's#https?://[^ ]+#<SUB_URL_REDACTED>#g; s#(secret|password|passwd|token|key)=.*#\1=<REDACTED>#Ig' | head -120 || true

echo "Done. OpenClash was not started automatically. Ask user which profile should be active."
