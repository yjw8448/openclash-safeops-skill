#!/bin/sh
# OpenClash subscription binding audit.
# Attempts to infer subscription records and their mapped config filenames without exposing URLs.
# Read-only. Useful when LuCI shows a YAML with "无订阅信息".

set -eu
URL_PATTERN='https?://[^[:space:]]+'

mask_secrets() {
  sed -E 's#https?://[^[:space:]]+#<SUB_URL_REDACTED>#g; s#(secret|password|passwd|token|key)=([^[:space:]]+)#\1=<REDACTED>#Ig'
}

printf '%s\n' "===== OpenClash Subscription Binding Audit ====="
date

printf '\n%s\n' "===== Raw UCI sections that may represent subscriptions, redacted ====="
uci show openclash 2>/dev/null | mask_secrets | grep -Ei 'subscribe|subscription|sub_|\.url=|\.address=|\.name=|\.config|\.file|\.yaml|\.yml|\.enabled|\.enable' || true

printf '\n%s\n' "===== Inferred subscription URL fingerprints ====="
URL_TMP="/tmp/openclash_binding_urls.$$"
(uci show openclash 2>/dev/null || true; grep -RhoE "$URL_PATTERN" /etc/openclash 2>/dev/null || true) \
  | grep -Eo "$URL_PATTERN" | sort -u > "$URL_TMP" 2>/dev/null || true
URL_COUNT="$(wc -l < "$URL_TMP" 2>/dev/null | tr -d ' ')"
echo "subscription_url_count=$URL_COUNT"
i=1
while IFS= read -r url; do
  [ -n "$url" ] || continue
  host="$(printf '%s' "$url" | sed -E 's#^[a-z]+://([^/:?]+).*#\1#')"
  fp="$(printf '%s' "$url" | cksum 2>/dev/null | awk '{print $1"-"$2}')"
  echo "subscription_$i host=$host fingerprint=$fp url=<SUB_URL_REDACTED>"
  i=$((i+1))
done < "$URL_TMP"
rm -f "$URL_TMP"

printf '\n%s\n' "===== Config filename references in UCI ====="
uci show openclash 2>/dev/null \
  | mask_secrets \
  | grep -Eio "[^'= ]+\.(yaml|yml)" \
  | sort -u || true

printf '\n%s\n' "===== Actual config files ====="
find /etc/openclash/config -maxdepth 1 -type f \( -name '*.yaml' -o -name '*.yml' \) -exec ls -lh {} \; 2>/dev/null | sort || true

printf '\n%s\n' "===== Orphan/unbound suspicion ====="
# A file is suspicious if its basename never appears in UCI. This is heuristic only.
UCI_TEXT="$(uci show openclash 2>/dev/null | mask_secrets || true)"
find /etc/openclash/config -maxdepth 1 -type f \( -name '*.yaml' -o -name '*.yml' \) 2>/dev/null | sort | while IFS= read -r f; do
  base="$(basename "$f")"
  if printf '%s\n' "$UCI_TEXT" | grep -Fq "$base"; then
    echo "bound_candidate=$f reason=filename_appears_in_uci"
  else
    echo "unbound_candidate=$f reason=filename_not_seen_in_uci"
  fi
done

printf '\n%s\n' "===== Decision ====="
if [ "$URL_COUNT" -gt 1 ]; then
  echo "DECISION=multi-subscription"
  echo "ACTION=Do not update all configs into one file. Require explicit mapping: subscription_1 -> file_A, subscription_2 -> file_B."
elif [ "$URL_COUNT" -eq 0 ]; then
  echo "DECISION=no-visible-subscription-record"
  echo "ACTION=Treat existing YAML as local/manual until user re-adds subscriptions or backup restores UCI binding."
else
  echo "DECISION=single-visible-subscription"
  echo "ACTION=Confirm selected YAML belongs to this subscription before update."
fi

echo "===== End subscription binding audit ====="
