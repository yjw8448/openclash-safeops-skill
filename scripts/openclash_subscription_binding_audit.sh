#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "subscription-to-YAML binding audit"
if have uci; then
  uci -q show openclash 2>/dev/null | grep -Ei 'config_path|config_update_url|subscribe|subscription|url|yaml' | redact_stream || true
fi
say ""
say "Config fingerprints:"
if have python3; then
  python3 "$SCRIPT_DIR/openclash_config_fingerprint.py" $(list_yaml_files | tr '\n' ' ') 2>/dev/null || true
else
  list_yaml_files | xargs -r ls -l 2>/dev/null
fi
