#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "quarantine unbound config"
file="${1:-${TARGET_FILE:-}}"
[ -n "$file" ] || fail "Usage: $0 /etc/openclash/config/name.yaml [--apply]"
case "$file" in /etc/openclash/config/*.yaml|/etc/openclash/config/*.yml) : ;; *) fail "Refusing non OpenClash config path: $file" ;; esac
[ -f "$file" ] || fail "File not found: $file"
qdir="/etc/openclash/quarantine-unbound"
qfile="$qdir/$(basename "$file").$(date +%Y%m%d-%H%M%S 2>/dev/null || echo now).bak"
say "Would copy: $file -> $qfile"
if [ "${2:-}" = "--apply" ]; then
  require_apply_flag
  mkdir -p "$qdir" || fail "Cannot create $qdir"
  cp -p "$file" "$qfile" || fail "Copy failed"
  say "Copied to quarantine backup: $qfile"
else
  say "Dry run. Re-run with --apply and I_UNDERSTAND_SAFEOPS_WRITE=1 to copy."
fi
