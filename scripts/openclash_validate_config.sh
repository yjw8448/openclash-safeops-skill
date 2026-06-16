#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
file="${1:-${TARGET_FILE:-}}"
[ -n "$file" ] || fail "Usage: $0 config.yaml"
python3 "$SCRIPT_DIR/openclash_lint_config.py" "$file"
python3 "$SCRIPT_DIR/openclash_group_detect.py" "$file" --env || true
