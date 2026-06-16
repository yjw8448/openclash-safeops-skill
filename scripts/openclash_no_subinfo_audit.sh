#!/bin/sh
# OpenClash unbound-config / "No subscription information" audit.
# Read-only by default. Designed for cases like: current profile pqjc.yaml shows 无订阅信息.
# It never prints full subscription URLs.

set -eu

TARGET_CONFIG="${TARGET_CONFIG:-}"
URL_PATTERN='https?://[^[:space:]]+'

mask_secrets() {
  sed -E 's#https?://[^[:space:]]+#<SUB_URL_REDACTED>#g; s#(secret|password|passwd|token|key)=([^[:space:]]+)#\1=<REDACTED>#Ig'
}

safe_cksum() {
  cksum "$1" 2>/dev/null | awk '{print $1"-"$2}' || true
}

print_config_summary() {
  f="$1"
  [ -f "$f" ] || return 0
  echo "----- file=$f -----"
  echo "size_bytes=$(wc -c < "$f" 2>/dev/null | tr -d ' ')"
  echo "fingerprint=$(safe_cksum "$f")"
  echo "mtime=$(date -r "$f" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || ls -l "$f" 2>/dev/null | awk '{print $6" "$7" "$8}')"
  echo "top_sections="
  grep -E '^(proxies:|proxy-groups:|rules:|proxy-providers:|rule-providers:|dns:|mixed-port:|redir-port:|tproxy-port:|port:)' "$f" 2>/dev/null | head -40 || true
  echo "names_sample="
  grep -E '^[[:space:]]*-?[[:space:]]*name:' "$f" 2>/dev/null | head -25 | mask_secrets || true
  echo "url_like_count=$(grep -Eo "$URL_PATTERN" "$f" 2>/dev/null | sort -u | wc -l | tr -d ' ')"
}

find_candidate_selected_files() {
  # Use TARGET_CONFIG if provided, then infer from UCI, then list common config files.
  [ -n "$TARGET_CONFIG" ] && printf '%s\n' "$TARGET_CONFIG"
  uci show openclash 2>/dev/null \
    | grep -Ei '(config|profile|yaml|yml|file|selected|enable)' \
    | sed -E "s#.*='?([^']*\.(yaml|yml))'?.*#\1#I" \
    | grep -Ei '\.(yaml|yml)$' || true
  find /etc/openclash/config -maxdepth 1 -type f \( -name '*.yaml' -o -name '*.yml' \) 2>/dev/null | sort || true
}

printf '%s\n' "===== OpenClash No-Subscription-Info Audit ====="
date
printf '%s\n' "TARGET_CONFIG=${TARGET_CONFIG:-auto}"

printf '\n%s\n' "===== UCI OpenClash summary, redacted ====="
uci show openclash 2>/dev/null | mask_secrets | grep -Ei 'config|sub|subscribe|url|name|yaml|yml|file|select|enable|update|convert|template|overwrite' || true

printf '\n%s\n' "===== Subscription-like URL inventory ====="
URL_TMP="/tmp/openclash_no_subinfo_urls.$$"
(uci show openclash 2>/dev/null || true; grep -RhoE "$URL_PATTERN" /etc/openclash 2>/dev/null || true) \
  | grep -Eo "$URL_PATTERN" | sort -u > "$URL_TMP" 2>/dev/null || true
URL_COUNT="$(wc -l < "$URL_TMP" 2>/dev/null | tr -d ' ')"
echo "subscription_url_count=$URL_COUNT"
if [ "$URL_COUNT" -gt 0 ]; then
  i=1
  while IFS= read -r url; do
    [ -n "$url" ] || continue
    host="$(printf '%s' "$url" | sed -E 's#^[a-z]+://([^/:?]+).*#\1#')"
    fp="$(printf '%s' "$url" | cksum 2>/dev/null | awk '{print $1"-"$2}')"
    echo "subscription_$i host=$host fingerprint=$fp url=<SUB_URL_REDACTED>"
    i=$((i+1))
  done < "$URL_TMP"
fi
rm -f "$URL_TMP"

printf '\n%s\n' "===== Candidate selected/config files ====="
FILES_TMP="/tmp/openclash_no_subinfo_files.$$"
find_candidate_selected_files | sed 's#^/etc/openclash/config/\?/etc/openclash/config/#/etc/openclash/config/#' | sort -u > "$FILES_TMP" 2>/dev/null || true
cat "$FILES_TMP" 2>/dev/null || true

printf '\n%s\n' "===== YAML summaries ====="
while IFS= read -r f; do
  [ -f "$f" ] || continue
  print_config_summary "$f"
done < "$FILES_TMP"
rm -f "$FILES_TMP"

printf '\n%s\n' "===== OpenClash backup/bad-state directories ====="
find /root /tmp /etc/openclash -maxdepth 5 -type d \
  \( -iname '*backup*' -o -iname '*safeops*' -o -iname '*bad*' -o -iname '*no-subinfo*' -o -iname '*merged*' \) \
  2>/dev/null | sort || true

printf '\n%s\n' "===== Interpretation ====="
if [ "$URL_COUNT" -eq 0 ]; then
  echo "STATE=no-subscription-url-found"
  echo "MEANING=Current OpenClash state has no subscription-like URL visible in UCI or /etc/openclash. Existing YAML may be a local/manual config."
elif [ "$URL_COUNT" -gt 1 ]; then
  echo "STATE=multi-subscription-risk"
  echo "MEANING=Multiple subscription-like URLs exist. Do not merge. Restore or rebuild one subscription -> one config mapping."
else
  echo "STATE=single-subscription-or-unbound-profile"
  echo "MEANING=One subscription-like URL exists, but selected YAML may still be unbound. Audit mapping before update."
fi

echo "POLICY=Do not treat an unbound YAML as the only correct source. Do not delete it; quarantine/backup first."
echo "NEXT=Run openclash_subscription_binding_audit.sh and identify pre-merge/pre-unbound backup before any write."
echo "===== End no-subscription-info audit ====="
