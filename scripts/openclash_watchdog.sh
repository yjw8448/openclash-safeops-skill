#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "watchdog verification"
backup="${1:-}"
if sh "$SCRIPT_DIR/openclash_verify_connectivity.sh"; then
  say "Verification command completed. Review output for failures."
else
  warn "Verification command failed."
  if [ -n "$backup" ]; then
    warn "Rollback candidate: $backup"
  fi
fi
