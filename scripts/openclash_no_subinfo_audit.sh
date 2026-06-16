#!/bin/sh
set -u
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/lib_safeops.sh"
print_header "no-subscription-info / unbound config audit"
say "Configs that may be local/unbound/generated:"
list_yaml_files | while IFS= read -r f; do
  [ -n "$f" ] || continue
  url_count=$(grep -Eic 'url:|proxy-provider|proxy-providers|subscription|config_update_url' "$f" 2>/dev/null || echo 0)
  bytes=$(wc -c <"$f" 2>/dev/null || echo 0)
  say "- $f bytes=$bytes provider/url markers=$url_count"
done
say ""
sh "$SCRIPT_DIR/openclash_subscription_binding_audit.sh" 2>/dev/null || true
say "Treat LuCI '无订阅信息' configs as unbound. Do not update them as normal subscription configs."
