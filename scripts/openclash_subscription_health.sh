#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "subscription health audit"
if have uci; then
  say "[1] Subscription-related UCI fields (redacted)"
  uci -q show openclash 2>/dev/null | grep -Ei 'subscribe|subscription|config_update_url|url|address' | redact_stream || true
fi
say ""
say "[2] Config files and possible provider URLs (redacted)"
list_yaml_files | while IFS= read -r f; do
  [ -n "$f" ] || continue
  say "--- $f"
  grep -En 'url:|path:|proxy-provider|proxy-providers|rule-provider|rule-providers|interval:' "$f" 2>/dev/null | head -n 60 | redact_stream || true
done
say ""
say "This is a read-only health audit. Raw subscription URLs are never printed."
