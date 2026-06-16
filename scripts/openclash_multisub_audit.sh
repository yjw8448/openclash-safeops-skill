#!/bin/sh
# OpenClash multi-subscription/profile audit. Read-only.
# It never prints full subscription URLs.

set -eu

echo "===== OpenClash Multi-Subscription Audit ====="
date

URL_PATTERN='https?://[^[:space:]]+'

mask_urls() {
  sed -E 's#https?://[^[:space:]]+#<SUB_URL_REDACTED>#g; s#(secret|password|passwd|token|key)=([^[:space:]]+)#\1=<REDACTED>#Ig'
}

fingerprint_text() {
  cksum 2>/dev/null | awk '{print $1"-"$2}'
}


collect_urls() {
  (uci show openclash 2>/dev/null || true; grep -RhoE "$URL_PATTERN" /etc/openclash 2>/dev/null || true) \
    | grep -Eo "$URL_PATTERN" \
    | sort -u || true
}

URL_TMP="/tmp/openclash_safeops_urls.$$"
collect_urls > "$URL_TMP" 2>/dev/null || true
URL_COUNT="$(wc -l < "$URL_TMP" 2>/dev/null | tr -d ' ')"
echo "subscription_url_count=$URL_COUNT"
if [ "$URL_COUNT" -gt 0 ]; then
  i=1
  while IFS= read -r url; do
    [ -n "$url" ] || continue
    fp="$(printf '%s' "$url" | fingerprint_text)"
    host="$(printf '%s' "$url" | sed -E 's#^[a-z]+://([^/:?]+).*#\1#')"
    echo "subscription_$i host=$host fingerprint=$fp url=<SUB_URL_REDACTED>"
    i=$((i+1))
  done < "$URL_TMP"
fi
rm -f "$URL_TMP"

echo
echo "===== UCI OpenClash summary redacted ====="
uci show openclash 2>/dev/null | mask_urls | grep -Ei 'config|sub|subscribe|url|name|yaml|yml|file|select|enable|dns|mode|template|convert|overwrite' || true

echo
echo "===== Candidate YAML/config files ====="
for d in /etc/openclash/config /etc/openclash /etc/openclash/history /etc/openclash/backup; do
  [ -d "$d" ] || continue
  find "$d" -maxdepth 2 -type f \( -name '*.yaml' -o -name '*.yml' -o -name '*.bak' -o -name '*.backup' \) 2>/dev/null | sort
done | while IFS= read -r f; do
  [ -f "$f" ] || continue
  size="$(wc -c < "$f" 2>/dev/null | tr -d ' ')"
  fp="$(cksum "$f" 2>/dev/null | awk '{print $1"-"$2}')"
  echo "--- file=$f size=$size fingerprint=$fp"
  grep -E '^(proxies:|proxy-groups:|rules:|proxy-providers:|rule-providers:|dns:)' "$f" 2>/dev/null | head -20 || true
  sample="$(grep -E '^[[:space:]]*-?[[:space:]]*name:' "$f" 2>/dev/null | head -10 | sed 's/^[[:space:]]*//' | tr '\n' ';' | mask_urls)"
  echo "groups_sample=$sample"
done

echo
echo "===== SafeOps/OpenClash backup directories ====="
find /root /tmp /etc/openclash -maxdepth 4 -type d \( -iname '*backup*' -o -iname '*bad-merged*' -o -iname '*safeops*' \) 2>/dev/null | sort || true

echo
echo "===== Merge-risk interpretation ====="
if [ "${URL_COUNT:-0}" -gt 1 ]; then
  echo "RISK=multi-subscription-detected"
  echo "POLICY=do-not-merge; preserve one subscription -> one config mapping unless user explicitly approves merge"
  echo "NEXT=run config fingerprints and identify pre-merge backup before any write"
else
  echo "RISK=single-or-unknown-subscription"
  echo "NEXT=still fingerprint configs before writing"
fi

echo "===== End multi-subscription audit ====="
