#!/bin/sh
# Read-only subscription health check.
# Usage:
#   SUB_URL='https://example.com/sub' sh openclash_subscription_health.sh
# Optional:
#   OUT=/tmp/sub-check.yaml sh openclash_subscription_health.sh
# This script redacts the URL in output and stores temporary content under /tmp.

set +e
SUB_URL="${SUB_URL:-}"
OUT="${OUT:-/tmp/openclash_sub_check.$$}"

mask_url() {
  [ -n "$1" ] && echo "provided-redacted" || echo "not-provided"
}

section() { echo; echo "## $1"; }
cmd_sh() { echo "+ $*"; sh -c "$*" 2>&1 | head -120 || true; }

cat <<HEADER
# OpenClash Subscription Health Check
Generated: $(date '+%Y-%m-%d %H:%M:%S %Z')
SUB_URL=$(mask_url "$SUB_URL")
Read-only.
HEADER

section "System time and TLS basics"
cmd_sh "date"
cmd_sh "opkg list-installed 2>/dev/null | grep -Ei 'ca-bundle|ca-certificates|curl|wget|openssl' || true"

if [ -z "$SUB_URL" ]; then
  echo "ERROR: SUB_URL env is empty. Example: SUB_URL='https://...' sh openclash_subscription_health.sh"
  exit 1
fi

section "Fetch subscription"
rm -f "$OUT" "$OUT.headers"
if command -v curl >/dev/null 2>&1; then
  curl -L --connect-timeout 10 --max-time 30 -A 'Clash/OpenClash SafeOps' -D "$OUT.headers" -o "$OUT" "$SUB_URL" 2>&1 | sed -E 's#(https?://)[^ ]+#\1***REDACTED***#g' || true
elif command -v wget >/dev/null 2>&1; then
  wget -S -T 30 -O "$OUT" "$SUB_URL" 2>&1 | sed -E 's#(https?://)[^ ]+#\1***REDACTED***#g' || true
else
  echo "ERROR: neither curl nor wget found."
  exit 2
fi

section "Headers and file summary"
[ -f "$OUT.headers" ] && sed -n '1,80p' "$OUT.headers" | sed -E 's#(https?://)[^ ]+#\1***REDACTED***#g' || true
ls -lah "$OUT" 2>/dev/null || true
BYTES="$(wc -c < "$OUT" 2>/dev/null || echo 0)"
echo "bytes=$BYTES"

section "Content type heuristics"
HEAD="$(head -c 300 "$OUT" 2>/dev/null | tr '\r' '\n')"
echo "$HEAD" | sed -n '1,20p' | sed -E 's#(server|password|passwd|token|secret|key):[[:space:]]*[^[:space:]]+#\1: ***REDACTED***#Ig'
if echo "$HEAD" | grep -qiE '<html|<!doctype|cloudflare|login|expired|forbidden|error'; then
  echo "WARNING: subscription response looks like HTML/login/error page, not a Clash config."
fi
if echo "$HEAD" | grep -qE '^(port|mixed-port|proxies|proxy-groups|rules|proxy-providers):'; then
  echo "Looks like YAML/Clash content."
elif echo "$HEAD" | grep -qE '^[A-Za-z0-9+/=[:space:]]+$'; then
  echo "Looks possibly Base64. Trying decode first lines..."
  if command -v base64 >/dev/null 2>&1; then
    base64 -d "$OUT" > "$OUT.decoded" 2>/dev/null && head -80 "$OUT.decoded" | sed -E 's#(server|password|passwd|token|secret|key):[[:space:]]*[^[:space:]]+#\1: ***REDACTED***#Ig' || echo "Base64 decode failed."
  fi
else
  echo "Unknown subscription content format."
fi

section "YAML structural keywords"
for f in "$OUT" "$OUT.decoded"; do
  [ -f "$f" ] || continue
  echo "### $f"
  grep -nE '^(proxies|Proxy|proxy-groups|proxy-providers|proxy-provider|rule-providers|rules|dns):' "$f" | head -50 || true
done

cat <<'HINTS'
Hints:
- 0 bytes, HTML, 403, login pages, or expired messages mean the subscription itself is unhealthy.
- If content has proxies but no proxy-groups, subscription conversion may be needed.
- If YAML exists but OpenClash fails, run openclash_lint_config.py on the converted/generated YAML.
HINTS
