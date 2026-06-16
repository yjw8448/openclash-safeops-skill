#!/bin/sh
# Read-only remote dependency audit for Aethersailor-style OpenClash templates.
# It checks whether representative repo/CDN/raw URLs are reachable and look like text/YAML.
set -u
TIMEOUT="${TIMEOUT:-8}"

urls='https://github.com/yjw8448/Aethersailor-Custom_OpenClash_Rules
https://raw.githubusercontent.com/yjw8448/Aethersailor-Custom_OpenClash_Rules/main/cfg/Custom_Clash.ini
https://testingcf.jsdelivr.net/gh/heunghingwan/Aethersailor-Custom_OpenClash_Rules@main/rule/Custom_Direct_Domain.yaml
https://testingcf.jsdelivr.net/gh/heunghingwan/Aethersailor-Custom_OpenClash_Rules@main/rule/Custom_Proxy_Domain.yaml
https://testingcf.jsdelivr.net/gh/heunghingwan/Aethersailor-Custom_OpenClash_Rules@main/rule/Steam_CDN_Classical.yaml
https://testingcf.jsdelivr.net/gh/heunghingwan/Aethersailor-Custom_OpenClash_Rules@main/rule/Custom_Port_Direct.yaml'

echo "===== Aethersailor remote dependency audit ====="
echo "READ_ONLY=1"
echo "timeout=${TIMEOUT}s"

if ! command -v curl >/dev/null 2>&1; then
  echo "WARN: curl not found; cannot audit remote dependencies. Do not write remote rule-providers automatically."
  exit 0
fi

echo "$urls" | while IFS= read -r url; do
  [ -n "$url" ] || continue
  echo "----- $url -----"
  code="$(curl -L -sS -o /tmp/oc_aether_probe.$$ -w '%{http_code}' --connect-timeout "$TIMEOUT" --max-time "$TIMEOUT" "$url" 2>/dev/null || echo FAIL)"
  ctype="$(curl -L -sSI --connect-timeout "$TIMEOUT" --max-time "$TIMEOUT" "$url" 2>/dev/null | awk 'BEGIN{IGNORECASE=1}/^content-type:/{print $0; exit}' | tr -d '\r')"
  echo "status=$code"
  [ -n "$ctype" ] && echo "$ctype" || true
  if [ "$code" != "200" ]; then
    echo "REMOTE_DEPENDENCY_UNSAFE=1"
  elif head -c 200 /tmp/oc_aether_probe.$$ 2>/dev/null | grep -qiE '<html|<!doctype|sign in|not found'; then
    echo "REMOTE_DEPENDENCY_UNSAFE=1"
    echo "reason=looks like html/login/error page"
  else
    echo "REMOTE_DEPENDENCY_OK=1"
  fi
  rm -f /tmp/oc_aether_probe.$$
done

echo "===== Decision ====="
echo "Use built-in local templates when any dependency is unsafe. Never inject unverified remote URLs into a target YAML."
