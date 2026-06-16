#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
file="${1:-${TARGET_FILE:-}}"
[ -n "$file" ] || fail "Usage: $0 config.yaml"
[ -f "$file" ] || fail "File not found: $file"
print_header "rule syntax smoke test"
grep -nE '^\s*-\s*(DOMAIN|DOMAIN-SUFFIX|DOMAIN-KEYWORD|IP-CIDR|GEOIP|GEOSITE|MATCH),' "$file" 2>/dev/null | head -n 80 || true
say "Run openclash_group_detect.py for strategy group reference checks."
