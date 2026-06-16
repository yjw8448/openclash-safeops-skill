#!/bin/sh
# Guard against accidental merging of multiple OpenClash subscriptions/configs.
# Default: read-only. Intended to be called before any write operation.

set -eu
MODE="${MULTISUB_MODE:-unknown}"   # expected: isolate, single-profile, intentional-merge
ALLOW="${ALLOW_MULTI_SUB_OPERATION:-0}"
TARGET_FILE="${TARGET_FILE:-}"
BINDING_REQUIRED="${BINDING_REQUIRED:-0}"
URL_PATTERN='https?://[^[:space:]]+'

echo "===== Multi-subscription write guard ====="
echo "MULTISUB_MODE=$MODE"
echo "ALLOW_MULTI_SUB_OPERATION=$ALLOW"
[ -n "$TARGET_FILE" ] && echo "TARGET_FILE=$TARGET_FILE"
echo "BINDING_REQUIRED=$BINDING_REQUIRED"

if [ -n "$TARGET_FILE" ] && [ "$BINDING_REQUIRED" = "1" ]; then
  base="$(basename "$TARGET_FILE")"
  if ! (uci show openclash 2>/dev/null || true) | grep -Fq "$base"; then
    echo "REFUSE: TARGET_FILE appears unbound; its basename is not referenced in OpenClash UCI."
    echo "This may correspond to LuCI showing 无订阅信息. Run openclash_no_subinfo_audit.sh and openclash_subscription_binding_audit.sh first."
    exit 4
  fi
fi

URL_COUNT="$( (uci show openclash 2>/dev/null || true; grep -RhoE "$URL_PATTERN" /etc/openclash 2>/dev/null || true) | grep -Eo "$URL_PATTERN" | sort -u | wc -l | tr -d ' ' )"
YAML_COUNT="$(find /etc/openclash/config /etc/openclash -maxdepth 2 -type f \( -name '*.yaml' -o -name '*.yml' \) 2>/dev/null | sort -u | wc -l | tr -d ' ')"

echo "subscription_url_count=$URL_COUNT"
echo "yaml_config_count=$YAML_COUNT"

if [ "$URL_COUNT" -gt 1 ]; then
  echo "Detected multiple subscription-like URLs. This environment must be treated as multi-profile."
  if [ "$MODE" = "intentional-merge" ] && [ "$ALLOW" = "1" ]; then
    echo "WARNING: intentional merge was explicitly allowed by environment variables. Proceed only if user approved."
    exit 0
  fi
  if [ "$MODE" = "isolate" ] || [ "$MODE" = "single-profile" ]; then
    echo "OK: operation declares it will preserve profile boundaries. Continue carefully."
    exit 0
  fi
  echo "REFUSE: MULTISUB_MODE is not set to isolate/single-profile. Do not write OpenClash config."
  echo "Set MULTISUB_MODE=isolate for boundary-preserving operations, or ask the user for an intentional merge."
  exit 3
fi

echo "OK: no multi-subscription risk detected by URL count. Still keep backups and fingerprints."
exit 0
