#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "active config/update URL binding audit"
if ! have uci; then fail "uci not found"; fi
say "OpenClash config path candidates:"
uci -q show openclash 2>/dev/null | grep -E 'config_path|config_update_url|auto_update|enable|config' | redact_stream || true
active=$(uci_get_safe openclash.config.config_path)
[ -n "$active" ] || active=$(uci_get_safe openclash.config.config_file)
[ -n "$active" ] && say "Detected active config field: $active" || warn "Could not determine active config path from common UCI keys."
say "If config_path and config_update_url belong to different providers, stop and ask the user which provider should be current."
