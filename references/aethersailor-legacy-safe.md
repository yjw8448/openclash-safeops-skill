# Aethersailor Legacy-Safe Adapter

Use this reference when the user wants one current YAML configured according to `yjw8448/Aethersailor-Custom_OpenClash_Rules` or an Aethersailor-style profile.

## Operating principle

Treat the upstream repository as design guidance, not as a blindly executable installer. Some subscription-conversion endpoints, ad-block snippets, remote rules, or maintainer-operated services may be stale, removed, or unavailable. Generate a local candidate YAML first and avoid system-wide OpenWrt edits.

## Auto-allowed scope

For exactly one target YAML, candidate generation may modify only:

- `dns`
- `sniffer`
- `rules`
- `rule-providers`
- `geodata-mode`
- `geox-url`

Do not modify:

- `proxies`
- `proxy-groups`
- `proxy-providers`
- subscription URLs
- other YAML files
- `/etc/config/network`
- `/etc/config/dhcp`
- `/etc/config/firewall`

## Manual-only system settings

List these as LuCI/manual checks instead of editing them by SSH:

- DNS redirection system switch
- WAN/LAN DNS settings
- IPv6 interface settings
- firewall zone settings
- DHCP/Dnsmasq global settings
- third-party DNS plugin installation or removal

## Deprecated or risky upstream features

Skip automatically unless the user explicitly requests and the dependency is verified:

- abandoned ad-block scripts
- subscription-conversion services that return 404/HTML/login pages
- remote rule files that cannot be fetched as plain text/YAML
- CDN mirrors whose content cannot be verified
- any EN_KEY/SUB_URL injection into public files

## Command pattern

```sh
TARGET_FILE="/etc/openclash/config/config-a(2).yaml"
sh scripts/openclash_multisub_audit.sh
sh scripts/openclash_subscription_binding_audit.sh
TARGET_FILE="$TARGET_FILE" sh scripts/openclash_single_config_template_guard.sh
TARGET_FILE="$TARGET_FILE" sh scripts/openclash_aethersailor_legacy_audit.sh
python3 scripts/openclash_template_apply.py \
  --target "$TARGET_FILE" \
  --template aethersailor-legacy-safe \
  --candidate /tmp/config-a2.aethersailor-legacy-safe.candidate.yaml
python3 scripts/openclash_lint_config.py /tmp/config-a2.aethersailor-legacy-safe.candidate.yaml
```

Apply only after user approval:

```sh
I_UNDERSTAND_TARGETED_WRITE=1 python3 scripts/openclash_template_apply.py \
  --target "$TARGET_FILE" \
  --template aethersailor-legacy-safe \
  --candidate /tmp/config-a2.aethersailor-legacy-safe.candidate.yaml \
  --apply
```

## Required report before writing

Report:

1. target YAML
2. candidate YAML
3. backup directory
4. detected subscription/config mapping
5. real proxy group names used
6. YAML sections changed
7. protected sections preserved
8. remote dependencies skipped or verified
9. LuCI/manual-only settings
10. rollback command
