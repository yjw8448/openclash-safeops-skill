#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "single-config template guard"
require_target_file
[ -f "$TARGET_FILE" ] || fail "TARGET_FILE does not exist: $TARGET_FILE"
yaml_count=$(list_yaml_files | wc -l | tr -d ' ')
say "Target file: $TARGET_FILE"
say "YAML files in config dir: $yaml_count"
if [ "${yaml_count:-0}" -gt 1 ] && [ "${I_UNDERSTAND_MULTISUB_TARGET:-}" != "1" ]; then
  warn "Multiple YAML files exist. This is allowed only for one explicit target."
fi
case "$TARGET_FILE" in
  *merged*.yaml|*merge*.yaml) warn "Target filename suggests merged config. Audit binding before writing." ;;
esac
say "Guard passed for candidate generation. Writing back still requires explicit apply flag."
