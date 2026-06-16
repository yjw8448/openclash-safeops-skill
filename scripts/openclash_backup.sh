#!/bin/sh
# Timestamped backup for OpenClash-related configs.
# Usage: sh openclash_backup.sh

set -eu
TS="$(date '+%Y%m%d-%H%M%S')"
BACKUP_DIR="/root/openclash-safeops-backup-$TS"
mkdir -p "$BACKUP_DIR"

copy_if_exists() {
  src="$1"
  dst="$2"
  if [ -e "$src" ]; then
    mkdir -p "$(dirname "$dst")"
    cp -a "$src" "$dst"
  fi
}

copy_if_exists /etc/config/openclash "$BACKUP_DIR/etc/config/openclash"
copy_if_exists /etc/config/network "$BACKUP_DIR/etc/config/network"
copy_if_exists /etc/config/dhcp "$BACKUP_DIR/etc/config/dhcp"
copy_if_exists /etc/config/firewall "$BACKUP_DIR/etc/config/firewall"
copy_if_exists /etc/openclash "$BACKUP_DIR/etc/openclash"
copy_if_exists /tmp/openclash.log "$BACKUP_DIR/tmp/openclash.log"
copy_if_exists /etc/smartdns "$BACKUP_DIR/etc/smartdns"
copy_if_exists /etc/config/smartdns "$BACKUP_DIR/etc/config/smartdns"

(uci show openclash 2>&1 || true) | sed -E 's#(https?://)[^ ]+#\1***REDACTED***#g; s/(password|passwd|secret|token|key)=.*/\1=***REDACTED***/Ig' > "$BACKUP_DIR/uci-openclash-redacted.txt"
uci show network > "$BACKUP_DIR/uci-network.txt" 2>&1 || true
uci show dhcp > "$BACKUP_DIR/uci-dhcp.txt" 2>&1 || true
uci show firewall > "$BACKUP_DIR/uci-firewall.txt" 2>&1 || true
uci show smartdns > "$BACKUP_DIR/uci-smartdns.txt" 2>&1 || true
ip addr > "$BACKUP_DIR/ip-addr.txt" 2>&1 || true
ip route > "$BACKUP_DIR/ip-route.txt" 2>&1 || true
ip -6 route > "$BACKUP_DIR/ip6-route.txt" 2>&1 || true

cat > "$BACKUP_DIR/MANIFEST.txt" <<MANIFEST
OpenClash SafeOps backup
Created: $(date '+%Y-%m-%d %H:%M:%S %Z')
Host: $(hostname 2>/dev/null || echo unknown)
Restore OpenClash only:
  sh openclash_rollback.sh $BACKUP_DIR
High-risk network/dhcp/firewall restore requires explicit confirmation.
MANIFEST

tar -czf "$BACKUP_DIR.tar.gz" -C "$(dirname "$BACKUP_DIR")" "$(basename "$BACKUP_DIR")"
echo "BACKUP_DIR=$BACKUP_DIR"
echo "BACKUP_TAR=$BACKUP_DIR.tar.gz"
