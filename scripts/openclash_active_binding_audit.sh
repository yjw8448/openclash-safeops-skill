#!/bin/sh
# Read-only audit for OpenClash active config_path / config_update_url consistency.
# Does not modify OpenClash, OpenWrt network, DHCP, firewall, or DNS.
set -eu

redact_url() {
  sed -E 's#(http|https)://[^[:space:]]+#<SUB_URL_REDACTED>#g; s#(password|passwd|secret|token|api[_-]?key)=([^[:space:]]+)#\1=<REDACTED>#Ig'
}

section() { echo; echo "===== $1 ====="; }

section "OpenClash active binding audit"
CONFIG_PATH="$(uci get openclash.config.config_path 2>/dev/null || true)"
AUTO_UPDATE="$(uci get openclash.config.auto_update 2>/dev/null || true)"
UPDATE_URL="$(uci get openclash.config.config_update_url 2>/dev/null || true)"

printf 'config_path: %s\n' "${CONFIG_PATH:-<empty>}"
printf 'auto_update: %s\n' "${AUTO_UPDATE:-<empty>}"
printf 'config_update_url: %s\n' "$(printf '%s' "$UPDATE_URL" | redact_url)"

section "Config files"
ls -lah /etc/openclash/config/ 2>/dev/null || true

section "OpenClash UCI subscription-ish fields redacted"
uci show openclash 2>/dev/null | grep -Ei 'config_path|config_update_url|sub|subscribe|url|auto_update|yaml|config' | redact_url || true

section "Heuristic notes"
echo "INFO: filename-owner checks are heuristic. config-b/config-a are known examples; for other providers compare the active config with subscription records and YAML fingerprints."
if [ -z "$CONFIG_PATH" ]; then
  echo "WARN: config_path is empty or unreadable. Active config is unclear."
fi
if [ "$AUTO_UPDATE" = "1" ] && [ -n "$UPDATE_URL" ]; then
  echo "INFO: auto_update is enabled and config_update_url is set. Auto-update may rewrite or reselect the active config."
else
  echo "INFO: auto_update is not clearly enabled, or config_update_url is empty."
fi
if [ -n "$CONFIG_PATH" ] && [ ! -f "$CONFIG_PATH" ]; then
  echo "WARN: config_path points to a missing file."
fi
case "$CONFIG_PATH" in
   *config-b*) echo "INFO: active config filename looks like config-b." ;;
   *config-a*) echo "INFO: active config filename looks like config-a." ;;
  *) echo "INFO: active config filename does not reveal subscription owner." ;;
esac

echo "RESULT: Read-only audit complete. Do not rewrite config_update_url unless the user chooses which subscription should be the current auto-update target."
