# Aethersailor Current-Safe Adapter

Use this reference for template profile `aethersailor-current-safe`.

## Goal

Adapt one existing subscription-managed OpenClash YAML to the current Aethersailor-style approach while avoiding stale remote services, deprecated ad-block snippets, and OpenWrt system config edits.

## Run pattern

```sh
TARGET_FILE="/etc/openclash/config/pqjc(2).yaml"
sh scripts/openclash_multisub_audit.sh
sh scripts/openclash_subscription_binding_audit.sh
TARGET_FILE="$TARGET_FILE" sh scripts/openclash_single_config_template_guard.sh
TARGET_FILE="$TARGET_FILE" sh scripts/openclash_aethersailor_legacy_audit.sh
sh scripts/openclash_aethersailor_remote_audit.sh
python3 scripts/openclash_template_apply.py \
  --target "$TARGET_FILE" \
  --template aethersailor-current-safe \
  --candidate /tmp/pqjc2.aethersailor-current-safe.candidate.yaml
python3 scripts/openclash_lint_config.py /tmp/pqjc2.aethersailor-current-safe.candidate.yaml
python3 scripts/openclash_group_detect.py /tmp/pqjc2.aethersailor-current-safe.candidate.yaml --env
```

## Write scope

Candidate generation may modify only:

- `dns`
- `sniffer`
- `rules`
- `rule-providers` only when remote dependencies are verified
- `geodata-mode`
- `geox-url` only when user requests and URLs are verified

Never modify:

- `proxies`
- `proxy-groups`
- `proxy-providers`
- subscription URLs
- other YAML files
- `/etc/config/network`
- `/etc/config/dhcp`
- `/etc/config/firewall`

## Manual-only items

List these as LuCI/manual checks instead of changing them:

- OpenClash running mode: Fake-IP enhanced/mixed/TUN choice
- OpenClash bypass-mainland-China switch
- DNS redirection switch in OpenWrt DHCP/DNS
- WAN DNS and IPv6 settings
- SmartDNS/MosDNS/AdGuardHome architecture changes
- ad-block-fast or other ad-block plugins

## Report before writing

Report target YAML, candidate path, backup path, subscription binding status, detected groups, changed YAML sections, protected sections, remote dependency status, skipped deprecated features, and rollback command. Apply only after user confirmation.
