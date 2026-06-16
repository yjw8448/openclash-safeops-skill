#!/bin/sh
# Read-only guard for applying a template to exactly one OpenClash YAML config.
# Usage:
#   TARGET_FILE=/etc/openclash/config/pqjc\(2\).yaml sh openclash_single_config_template_guard.sh
#   sh openclash_single_config_template_guard.sh /etc/openclash/config/pqjc\(2\).yaml

set -u
TARGET_FILE="${TARGET_FILE:-${1:-}}"

say(){ printf '%s\n' "$*"; }
fail(){ say "ERROR: $*"; exit 2; }
warn(){ say "WARN: $*"; }

say "===== Single-config template guard ====="
[ -n "$TARGET_FILE" ] || fail "TARGET_FILE is required. Refuse to apply a template without an explicit target YAML."
case "$TARGET_FILE" in
  /etc/openclash/config/*.yaml|/etc/openclash/config/*.yml) ;;
  *) fail "Target must be one file under /etc/openclash/config/*.yaml or *.yml: $TARGET_FILE" ;;
esac
[ -f "$TARGET_FILE" ] || fail "Target file does not exist: $TARGET_FILE"

say "TARGET_FILE=$TARGET_FILE"
say "sha256=$(sha256sum "$TARGET_FILE" 2>/dev/null | awk '{print $1}')"
say "size_bytes=$(wc -c < "$TARGET_FILE" 2>/dev/null || echo 0)"

say "===== YAML files in /etc/openclash/config ====="
find /etc/openclash/config -maxdepth 1 -type f \( -name '*.yaml' -o -name '*.yml' \) 2>/dev/null | sort | while read -r f; do
  [ -f "$f" ] || continue
  if [ "$f" = "$TARGET_FILE" ]; then mark='*'; else mark=' '; fi
  printf '%s %s %s\n' "$mark" "$(sha256sum "$f" 2>/dev/null | awk '{print $1}')" "$f"
done

say "===== UCI subscription/config hints, redacted ====="
uci show openclash 2>/dev/null | sed -E 's#(http|https)://[^ ]+#<SUB_URL_REDACTED>#g; s#secret=.*#secret=<REDACTED>#g; s#password=.*#password=<REDACTED>#g' || true

say "===== Target top-level sections ====="
grep -E '^(dns:|sniffer:|tun:|proxies:|proxy-groups:|proxy-providers:|rule-providers:|rules:)' "$TARGET_FILE" 2>/dev/null || true

say "===== Guard decision ====="
say "OK_READ_ONLY: target is explicit and exists."
say "NEXT: create backup, generate candidate, lint candidate, show diff summary, ask user before overwriting."

exit 0
