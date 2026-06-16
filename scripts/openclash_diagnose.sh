#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "read-only diagnosis"
say "[1] System basics"
( uname -a 2>/dev/null || true ) | redact_stream
( date 2>/dev/null || true ) | redact_stream
say ""
say "[2] OpenClash service"
service_status_safe openclash | redact_stream
say ""
say "[3] Core services relevant to router access"
service_status_safe dnsmasq | redact_stream
service_status_safe uhttpd | redact_stream
say ""
say "[4] UCI OpenClash summary (redacted)"
if have uci; then
  uci -q show openclash 2>/dev/null | redact_stream || true
else
  warn "uci not found"
fi
say ""
say "[5] YAML files"
list_yaml_files | while IFS= read -r f; do
  [ -n "$f" ] || continue
  bytes=$(wc -c <"$f" 2>/dev/null || echo 0)
  say "- $f (${bytes} bytes)"
done
say ""
say "[6] DNS/ports"
if have ss; then ss -lntup 2>/dev/null | grep -E '(:53|:80|:443|:789|:909)' | redact_stream || true
elif have netstat; then netstat -lntup 2>/dev/null | grep -E '(:53|:80|:443|:789|:909)' | redact_stream || true
fi
say ""
say "[7] Recent OpenClash logs"
if have logread; then logread 2>/dev/null | grep -i openclash | tail -n 80 | redact_stream || true
fi
say ""
say "Diagnosis finished. No network/dhcp/firewall files were modified."
