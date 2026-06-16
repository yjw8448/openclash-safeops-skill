#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "emergency restore"
say "Emergency scope: stop OpenClash, restart dnsmasq/uhttpd only. No network restart, no reboot, no network/dhcp/firewall edits."
if [ "${1:-}" != "--apply" ]; then
  say "Dry run. To apply: I_UNDERSTAND_SAFEOPS_WRITE=1 sh $0 --apply"
  exit 0
fi
require_apply_flag
sh "$SCRIPT_DIR/openclash_backup.sh" || warn "Backup failed or incomplete; continuing only if services can recover access."
[ -x /etc/init.d/openclash ] && /etc/init.d/openclash stop 2>&1 | redact_stream || warn "openclash init script missing"
[ -x /etc/init.d/dnsmasq ] && /etc/init.d/dnsmasq restart 2>&1 | redact_stream || warn "dnsmasq init script missing"
[ -x /etc/init.d/uhttpd ] && /etc/init.d/uhttpd restart 2>&1 | redact_stream || true
say "Emergency restore commands finished. Verify SSH/LuCI/DNS before any further repair."
