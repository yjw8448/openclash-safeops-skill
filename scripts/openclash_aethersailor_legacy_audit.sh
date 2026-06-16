#!/bin/sh
# Aethersailor Legacy-Safe audit for OpenClash SafeOps.
# Read-only. Prints whether it is safe to generate an Aethersailor-style candidate.
set -eu
TARGET_FILE="${TARGET_FILE:-${1:-}}"
if [ -z "$TARGET_FILE" ]; then
  echo "ERROR: set TARGET_FILE=/etc/openclash/config/example.yaml or pass target file as argv[1]" >&2
  exit 2
fi

echo "===== Aethersailor Legacy-Safe Audit ====="
echo "target=$TARGET_FILE"
[ -f "$TARGET_FILE" ] || { echo "ERROR: target file not found" >&2; exit 2; }

echo "===== Target fingerprint ====="
sha256sum "$TARGET_FILE" 2>/dev/null || true
ls -lh "$TARGET_FILE" 2>/dev/null || true

echo "===== Config files present ====="
find /etc/openclash/config -maxdepth 1 -type f \( -name "*.yaml" -o -name "*.yml" \) -exec ls -lh {} \; 2>/dev/null | sort || true

echo "===== OpenClash UCI redacted ====="
uci show openclash 2>/dev/null | sed -E 's#(http|https)://[^ ]+#<SUB_URL_REDACTED>#g; s#secret=.*#secret=<REDACTED>#g; s#password=.*#password=<REDACTED>#g' || true

echo "===== System/DNS services (read-only) ====="
/etc/init.d/openclash status 2>/dev/null || true
/etc/init.d/dnsmasq status 2>/dev/null || true
/etc/init.d/smartdns status 2>/dev/null || true
/etc/init.d/AdGuardHome status 2>/dev/null || true
/etc/init.d/mosdns status 2>/dev/null || true
netstat -lntup 2>/dev/null | grep -E ':53|:7874|:6053|:6553|:7890|:7891|:9090' || true

echo "===== Target YAML sections ====="
grep -E '^(dns:|sniffer:|tun:|proxies:|proxy-groups:|proxy-providers:|rule-providers:|rules:|geodata-mode:|geox-url:)' "$TARGET_FILE" 2>/dev/null || true

echo "===== Remote dependency URLs found in target (redacted) ====="
grep -RhoE 'https?://[^[:space:]<>]+' "$TARGET_FILE" 2>/dev/null | sed -E 's#(https?://[^/]+)/.*#\1/<REDACTED_PATH>#g' | sort -u || true

echo "===== Decision hints ====="
echo "AUTO_SAFE=YAML_CANDIDATE_ONLY"
echo "AUTO_ALLOWED_SECTIONS=dns,sniffer,rules,rule-providers,geodata-mode,geox-url"
echo "AUTO_FORBIDDEN=network,dhcp,firewall,proxies,proxy-groups,proxy-providers,subscription-url,other-yaml"
echo "NOTE=Do not apply abandoned ad scripts or unverified remote subscription-conversion services automatically."

echo "===== Aethersailor Current-Safe source rules ====="
echo "RECOMMENDED_MODE=Fake-IP only; do not mix with Redir-Host"
echo "DNS_RECOMMENDATION=Nameserver uses system/WAN/verified upstream; fallback empty by default"
echo "NO_NESTING=Avoid SmartDNS/MosDNS/AdGuardHome unless intentionally designed by user"
echo "ADBLOCK=Deprecated/not recommended; do not apply automatically"
echo "RULE_ORDER=private/direct -> custom direct/proxy -> games/download/BT -> AI/GitHub/media -> cn -> final"
echo "TEMPLATE=cfg/Custom_Clash.ini source logic; use local candidate generation unless remote dependencies pass audit"
