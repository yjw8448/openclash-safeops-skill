#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "backup"
backup_dir=$(make_backup_dir)
say "Backup directory: $backup_dir"
if [ -f "$OPENCLASH_UCI" ]; then
  cp -p "$OPENCLASH_UCI" "$backup_dir/openclash.uci" || fail "Failed to copy $OPENCLASH_UCI"
fi
if [ -d "$OPENCLASH_ROOT_DIR" ]; then
  tar -czf "$backup_dir/openclash-root.tar.gz" -C / etc/openclash 2>/dev/null || warn "Could not archive /etc/openclash"
fi
# Visibility-only backups. These must never be written by SafeOps normal repair.
for f in /etc/config/network /etc/config/dhcp /etc/config/firewall; do
  [ -f "$f" ] && cp -p "$f" "$backup_dir/$(basename "$f").visibility-only" 2>/dev/null || true
done
find "$backup_dir" -maxdepth 1 -type f -print | sort
say "Backup complete. Visibility-only system configs were copied for rollback reference only."
