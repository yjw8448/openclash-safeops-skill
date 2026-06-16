#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "DNS audit"
say "[1] Port 53 listeners"
if have ss; then ss -lntup 2>/dev/null | grep ':53' | redact_stream || say "No :53 listener shown by ss"
elif have netstat; then netstat -lntup 2>/dev/null | grep ':53' | redact_stream || say "No :53 listener shown by netstat"
else warn "ss/netstat not found"; fi
say ""
say "[2] dnsmasq status"
service_status_safe dnsmasq | redact_stream
say ""
say "[3] OpenClash DNS-related UCI options"
if have uci; then
  uci -q show openclash 2>/dev/null | grep -Ei 'dns|fake|redir|fallback|nameserver|enhanced|listen|ipv6' | redact_stream || true
fi
say ""
say "[4] Other DNS plugins/process names"
ps 2>/dev/null | grep -Ei 'smartdns|mosdns|adguard|dnsmasq|openclash|mihomo|clash' | grep -v grep | redact_stream || true
say ""
say "Audit only. Do not change system DNS/DHCP/firewall from this script."
