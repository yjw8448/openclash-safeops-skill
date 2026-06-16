#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "multi-config restore planner"
backup="${1:-}"
[ -n "$backup" ] || fail "Usage: $0 /etc/openclash/safeops-backups/YYYYmmdd-HHMMSS"
[ -d "$backup" ] || fail "Backup dir not found: $backup"
say "Backup contents:"
find "$backup" -maxdepth 1 -type f -print | sort
say "This script only plans multi-config restore. Use openclash_rollback.sh for explicit restore after review."
