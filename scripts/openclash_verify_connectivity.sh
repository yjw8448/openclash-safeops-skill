#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "post-change connectivity verification"
say "[1] Default route"
( ip route 2>/dev/null || route -n 2>/dev/null || true ) | redact_stream
say "[2] DNS resolution"
if have nslookup; then nslookup openwrt.org 127.0.0.1 2>&1 | head -n 30 | redact_stream || true
elif have ping; then ping -c 1 openwrt.org 2>&1 | head -n 20 | redact_stream || true
fi
say "[3] Basic connectivity"
if have ping; then ping -c 2 1.1.1.1 2>&1 | redact_stream || true; fi
say "[4] OpenClash service"
service_status_safe openclash | redact_stream
