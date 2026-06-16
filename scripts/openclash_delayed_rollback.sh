#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "delayed rollback scheduler"
backup="${1:-}"
seconds="${2:-120}"
[ -n "$backup" ] || fail "Usage: I_UNDERSTAND_SAFEOPS_WRITE=1 $0 BACKUP_DIR [seconds] --apply"
[ "${3:-}" = "--apply" ] || { say "Dry run. Would rollback $backup after $seconds seconds."; exit 0; }
require_apply_flag
( sleep "$seconds"; I_UNDERSTAND_SAFEOPS_WRITE=1 sh "$SCRIPT_DIR/openclash_rollback.sh" "$backup" --apply ) >/tmp/openclash-safeops-delayed-rollback.log 2>&1 &
say "Delayed rollback scheduled in background. Cancel manually if verification succeeds. Log: /tmp/openclash-safeops-delayed-rollback.log"
