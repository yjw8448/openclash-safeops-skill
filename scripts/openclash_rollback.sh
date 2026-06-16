#!/bin/sh
# Restore backup made by openclash_backup.sh.
# Usage: sh openclash_rollback.sh /root/openclash-safeops-backup-YYYYmmdd-HHMMSS
# Default restores OpenClash only. Add --include-network only after explicit high-risk confirmation.

set -eu
BACKUP_DIR="${1:-}"
INCLUDE_NETWORK=0
[ "${2:-}" = "--include-network" ] && INCLUDE_NETWORK=1

if [ -z "$BACKUP_DIR" ] || [ ! -d "$BACKUP_DIR" ]; then
  echo "Usage: sh openclash_rollback.sh /root/openclash-safeops-backup-YYYYmmdd-HHMMSS [--include-network]"
  exit 1
fi

restore_if_exists() {
  src="$1"
  dst="$2"
  if [ -e "$src" ]; then
    echo "+ restore $dst"
    rm -rf "$dst"
    cp -a "$src" "$dst"
  fi
}

[ -x /etc/init.d/openclash ] && /etc/init.d/openclash stop || true
restore_if_exists "$BACKUP_DIR/etc/config/openclash" /etc/config/openclash
restore_if_exists "$BACKUP_DIR/etc/openclash" /etc/openclash
restore_if_exists "$BACKUP_DIR/etc/config/smartdns" /etc/config/smartdns
restore_if_exists "$BACKUP_DIR/etc/smartdns" /etc/smartdns

if [ "$INCLUDE_NETWORK" = "1" ]; then
  echo "HIGH-RISK: restoring network/dhcp/firewall files because --include-network was provided."
  restore_if_exists "$BACKUP_DIR/etc/config/network" /etc/config/network
  restore_if_exists "$BACKUP_DIR/etc/config/dhcp" /etc/config/dhcp
  restore_if_exists "$BACKUP_DIR/etc/config/firewall" /etc/config/firewall
else
  echo "Network/DHCP/firewall backups were NOT auto-restored to avoid lockout."
fi

[ -x /etc/init.d/dnsmasq ] && /etc/init.d/dnsmasq restart || true
[ -x /etc/init.d/firewall ] && [ "$INCLUDE_NETWORK" = "1" ] && /etc/init.d/firewall restart || true

echo "Rollback complete for selected scope. Suggested next checks:"
echo "  ip route"
echo "  nslookup openwrt.org 127.0.0.1"
echo "  /etc/init.d/openclash start"
