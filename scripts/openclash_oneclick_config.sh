#!/bin/sh
# Safe one-click OpenClash baseline generator.
# Default dry-run; requires --apply to write template files.
# This script does not edit network/dhcp/firewall.
#
# Usage examples:
#   SUB_URL='https://example.com/sub' PROFILE=fakeip-aethersailor sh openclash_oneclick_config.sh
#   SUB_URL='https://example.com/sub' PROFILE=fakeip-aethersailor sh openclash_oneclick_config.sh --apply
#   PROFILE=redirhost-smartdns sh openclash_oneclick_config.sh --apply
#   PROFILE=minimal-safe sh openclash_oneclick_config.sh --apply

set -eu
APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1
PROFILE="${PROFILE:-fakeip-aethersailor}"
SUB_URL="${SUB_URL:-}"
TARGET_DIR="/etc/openclash/safeops"

mask_url() {
  [ -n "$1" ] && echo "provided-redacted" || echo "not-provided"
}

write_file() {
  path="$1"
  content="$2"
  echo "+ write $path"
  if [ "$APPLY" = "1" ]; then
    mkdir -p "$(dirname "$path")"
    printf '%s\n' "$content" > "$path"
  fi
}

if [ "$APPLY" = "0" ]; then
  echo "DRY-RUN mode. Nothing will be changed. Re-run with --apply to write files."
else
  # v5 guard: refuse write operations in multi-subscription environments unless
  # the caller explicitly declares boundary-preserving intent.
  if [ -f ./openclash_multisub_guard.sh ]; then
    MULTISUB_MODE="${MULTISUB_MODE:-isolate}" sh ./openclash_multisub_guard.sh
  elif [ -f /tmp/openclash_multisub_guard.sh ]; then
    MULTISUB_MODE="${MULTISUB_MODE:-isolate}" sh /tmp/openclash_multisub_guard.sh
  else
    echo "Warning: multi-subscription guard script not found; do not use this script to merge subscriptions."
  fi
  if [ -f ./openclash_backup.sh ]; then sh ./openclash_backup.sh; elif [ -f /tmp/openclash_backup.sh ]; then sh /tmp/openclash_backup.sh; else echo "ERROR: backup script missing"; exit 2; fi
fi

echo "PROFILE=$PROFILE"
echo "SUB_URL=$(mask_url "$SUB_URL")"
echo "TARGET_DIR=$TARGET_DIR"

echo "# Dependency check"
for bin in uci curl; do command -v "$bin" >/dev/null 2>&1 || echo "Missing: $bin"; done
[ -x /etc/init.d/openclash ] || echo "Warning: /etc/init.d/openclash not found"

LAN_SUMMARY="$(ip -br addr 2>/dev/null | grep -E 'br-lan|lan' || true)"
IPV6_SUMMARY="$(ip -6 addr 2>/dev/null | grep -E 'scope global' | head -5 || true)"

case "$PROFILE" in
  fakeip-aethersailor)
    PROFILE_NOTES="# fakeip-aethersailor profile

LuCI review checklist:
- Core: Mihomo/Meta.
- Mode: Rule.
- Fake-IP only if the LAN/app environment is compatible.
- Subscription conversion: use a trusted Aethersailor-style template when compatible.
- DNS: ensure OpenClash/dnsmasq chain has no competing DNS hijacker.
- Rules/overwrite: import generated snippets only after group names are verified.

Detected LAN:
$LAN_SUMMARY

Detected global IPv6:
$IPV6_SUMMARY
"
    ;;
  redirhost-smartdns)
    PROFILE_NOTES="# redirhost-smartdns profile

LuCI review checklist:
- Mode: Redir-Host compatibility.
- DNS: Dnsmasq forwarding.
- SmartDNS CN/GW grouping only if SmartDNS is installed and healthy.
- Avoid multiple 53-port hijackers.
- IPv6 OpenClash toggles are medium risk; OpenWrt WAN/LAN IPv6-PD/RA/DHCPv6 changes are high risk.
- Run DNS leak tests after setup.

Detected LAN:
$LAN_SUMMARY

Detected global IPv6:
$IPV6_SUMMARY
"
    ;;
  minimal-safe)
    PROFILE_NOTES="# minimal-safe profile

LuCI review checklist:
- Do not change network/dhcp/firewall.
- Use generated rule snippets only.
- Validate YAML and group names before starting OpenClash.
- Best choice when the router was recently locked out or unstable.

Detected LAN:
$LAN_SUMMARY
"
    ;;
  *)
    echo "Unknown PROFILE. Use PROFILE=fakeip-aethersailor, PROFILE=redirhost-smartdns, or PROFILE=minimal-safe."
    exit 1
    ;;
esac

RULE_PROVIDERS_CONTENT="rule-providers:
  safeops_ai:
    type: file
    behavior: classical
    path: ./safeops/rules-ai-classical.yaml
    interval: 86400
  safeops_dev:
    type: file
    behavior: classical
    path: ./safeops/rules-dev-classical.yaml
    interval: 86400
"

AI_RULES_CONTENT="payload:
  - DOMAIN-SUFFIX,openai.com
  - DOMAIN-SUFFIX,chatgpt.com
  - DOMAIN-SUFFIX,anthropic.com
  - DOMAIN-SUFFIX,claude.ai
  - DOMAIN-SUFFIX,ai.com
"

DEV_RULES_CONTENT="payload:
  - DOMAIN-SUFFIX,github.com
  - DOMAIN-SUFFIX,githubusercontent.com
  - DOMAIN-SUFFIX,githubassets.com
  - DOMAIN-SUFFIX,ghcr.io
  - DOMAIN-SUFFIX,docker.com
  - DOMAIN-SUFFIX,docker.io
  - DOMAIN-SUFFIX,npmjs.org
  - DOMAIN-SUFFIX,pypi.org
  - DOMAIN-SUFFIX,pythonhosted.org
"

RULES_CONTENT="# SafeOps suggested rule order. Replace AI/Proxy group names if your config uses different names.
rules:
  - DOMAIN-SUFFIX,local,DIRECT
  - DOMAIN-SUFFIX,lan,DIRECT
  - IP-CIDR,10.0.0.0/8,DIRECT,no-resolve
  - IP-CIDR,172.16.0.0/12,DIRECT,no-resolve
  - IP-CIDR,192.168.0.0/16,DIRECT,no-resolve
  - IP-CIDR,127.0.0.0/8,DIRECT,no-resolve
  - DOMAIN-SUFFIX,openai.com,AI
  - DOMAIN-SUFFIX,chatgpt.com,AI
  - DOMAIN-SUFFIX,anthropic.com,AI
  - DOMAIN-SUFFIX,claude.ai,AI
  - DOMAIN-SUFFIX,github.com,Proxy
  - DOMAIN-SUFFIX,githubusercontent.com,Proxy
  - DOMAIN-SUFFIX,docker.com,Proxy
  - DOMAIN-SUFFIX,docker.io,Proxy
  - GEOSITE,cn,DIRECT
  - GEOIP,CN,DIRECT
  - MATCH,Proxy
"

OVERWRITE_NOTES="# SafeOps overwrite notes

Do not paste this blindly into a generated YAML unless group names are verified.

Required strategy groups if using generated rules:
- AI
- Proxy
- DIRECT is built-in

Recommended process:
1. Let OpenClash generate a working config from subscription.
2. Export or inspect the OpenClash-modified runtime config.
3. Verify proxy group names.
4. Import custom rule snippets through OpenClash overwrite/rule-provider page.
5. Restart OpenClash only.
6. Run DNS and rule tests.
"

write_file "$TARGET_DIR/README-apply-in-luci.md" "$PROFILE_NOTES"
write_file "$TARGET_DIR/safeops-rule-providers.yaml" "$RULE_PROVIDERS_CONTENT"
write_file "$TARGET_DIR/rules-ai-classical.yaml" "$AI_RULES_CONTENT"
write_file "$TARGET_DIR/rules-dev-classical.yaml" "$DEV_RULES_CONTENT"
write_file "$TARGET_DIR/safeops-suggested-rules.yaml" "$RULES_CONTENT"
write_file "$TARGET_DIR/safeops-overwrite-notes.yaml" "$OVERWRITE_NOTES"

cat <<DONE
# Generated profile assets.
# No /etc/config/network, /etc/config/dhcp, or /etc/config/firewall changes were made.
# No OpenClash UCI changes were made because option names differ by OpenClash version.
# Apply through LuCI after reading $TARGET_DIR/README-apply-in-luci.md.
DONE
