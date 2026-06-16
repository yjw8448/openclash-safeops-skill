#!/bin/sh
# Static + live rule sanity checks. Read-only.
# Optional env:
#   CONFIG=/etc/openclash/config.yaml
#   PROXY=http://127.0.0.1:7890
#   OC_API=http://127.0.0.1:9090
#   OC_SECRET=dashboard_secret

set +e
CONFIG="${CONFIG:-/etc/openclash/config.yaml}"
PROXY="${PROXY:-http://127.0.0.1:7890}"
OC_API="${OC_API:-http://127.0.0.1:9090}"
DOMAINS="${DOMAINS:-openai.com chatgpt.com github.com docker.com baidu.com bilibili.com openwrt.org}"

section() { echo; echo "## $1"; }
cmd_sh() { echo "+ $*"; sh -c "$*" 2>&1 | head -120 || true; }

cat <<HEADER
# OpenClash Rule Test
Generated: $(date '+%Y-%m-%d %H:%M:%S %Z')
CONFIG=$CONFIG
Read-only.
HEADER

section "Static config snippets"
if [ -f "$CONFIG" ]; then
  echo "### proxy groups"
  grep -nE '^  - name:|^- name:|^proxy-groups:|^rules:' "$CONFIG" | head -120 || true
  echo "### domain rule coverage"
  for d in $DOMAINS; do
    echo "--- $d"
    grep -ni "$d" "$CONFIG" | head -20 || echo "no direct textual match"
  done
else
  echo "Config not found: $CONFIG"
fi

section "DNS checks"
for d in $DOMAINS; do
  cmd_sh "nslookup $d 127.0.0.1"
done

section "Proxy live checks"
for d in $DOMAINS; do
  cmd_sh "curl -I -L --proxy '$PROXY' --connect-timeout 5 --max-time 15 https://$d"
done

section "Dashboard/API rules/proxies"
AUTH=""
[ -n "${OC_SECRET:-}" ] && AUTH="Authorization: Bearer ${OC_SECRET}"
if [ -n "$AUTH" ]; then
  curl -sS --connect-timeout 3 --max-time 8 -H "$AUTH" "$OC_API/proxies" 2>&1 | head -120 || true
  curl -sS --connect-timeout 3 --max-time 8 -H "$AUTH" "$OC_API/rules" 2>&1 | head -120 || true
else
  cmd_sh "curl -sS --connect-timeout 3 --max-time 8 '$OC_API/proxies'"
  cmd_sh "curl -sS --connect-timeout 3 --max-time 8 '$OC_API/rules'"
fi

cat <<'HINTS'
Notes:
- This script cannot perfectly prove which rule matched unless the core/API exposes match details.
- It is still useful to confirm DNS, proxy connectivity, API availability, and whether rules mention expected domains.
HINTS
