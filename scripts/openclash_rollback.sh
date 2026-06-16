#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "rollback"
backup="${1:-}"
[ -n "$backup" ] || fail "Usage: I_UNDERSTAND_SAFEOPS_WRITE=1 $0 /etc/openclash/safeops-backups/YYYYmmdd-HHMMSS --apply"
[ -d "$backup" ] || fail "Backup dir not found: $backup"
say "Backup: $backup"
find "$backup" -maxdepth 1 -type f -print | sort
if [ "${2:-}" != "--apply" ]; then
  say "Dry run. Re-run with --apply and I_UNDERSTAND_SAFEOPS_WRITE=1."
  exit 0
fi
require_apply_flag
if [ -f "$backup/openclash.uci" ]; then
  cp -p "$backup/openclash.uci" /etc/config/openclash || fail "restore UCI failed"
fi
if [ -f "$backup/openclash-root.tar.gz" ]; then
  tar -xzf "$backup/openclash-root.tar.gz" -C / || fail "restore /etc/openclash failed"
fi
[ -x /etc/init.d/openclash ] && /etc/init.d/openclash restart 2>&1 | redact_stream || true
say "Rollback applied. Verify connectivity."
