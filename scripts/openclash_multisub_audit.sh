#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "multi-subscription audit"
yaml_count=$(list_yaml_files | wc -l | tr -d ' ')
say "YAML file count: $yaml_count"
list_yaml_files | sed 's/^/- /'
say ""
if have uci; then
  say "Subscription/update related UCI entries (redacted):"
  uci -q show openclash 2>/dev/null | grep -Ei 'config_path|config_update_url|subscribe|subscription|url' | redact_stream || true
fi
say ""
if [ "${yaml_count:-0}" -gt 1 ]; then
  warn "Multiple YAML files detected. Do not merge or overwrite until binding is proven."
fi
