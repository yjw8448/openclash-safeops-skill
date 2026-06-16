#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "multi-subscription prewrite guard"
yaml_count=$(list_yaml_files | wc -l | tr -d ' ')
if [ "${yaml_count:-0}" -gt 1 ] && [ "${I_UNDERSTAND_MULTISUB_TARGET:-}" != "1" ]; then
  list_yaml_files | sed 's/^/- /'
  fail "Multiple YAML files detected. Refusing write unless exact TARGET_FILE and I_UNDERSTAND_MULTISUB_TARGET=1 are provided."
fi
say "Guard passed: no ambiguous multi-YAML write detected."
