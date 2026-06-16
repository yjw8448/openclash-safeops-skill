# Aethersailor Current-Safe Config Generation

Use when the user asks to configure exactly one current OpenClash YAML using Aethersailor/yjw8448 rules or `Custom_Clash.ini` ideas. Treat upstream/fork content as design guidance, not an installer.

## Decision path

1. Confirm one explicit target YAML, for example `/etc/openclash/config/config-a(2).yaml`.
2. Run multi-subscription and binding audits. Stop if the target mapping is unknown or if LuCI shows `无订阅信息`.
3. Detect real strategy groups in the target YAML. Map `ChatGPT`, `AI服务`, `GitHub`, media, Steam, and final rules only to groups that already exist.
4. Run remote dependency audit, but default to local rules if GitHub/raw/CDN/converter URLs are unavailable or return HTML/404.
5. Generate a candidate with `--template aethersailor-current-safe`.
6. Lint the candidate, report changed sections, and wait for user approval before writing back to the same file.

## YAML-level scope

Allowed candidate sections:

- `dns`
- `sniffer`
- `rules`
- `rule-providers` only when URLs are verified
- `geodata-mode` / `geox-url` only when the user requests and URLs are verified

Protected sections:

- `proxies`
- `proxy-groups`
- `proxy-providers`
- subscription URLs
- other YAML files
- `/etc/config/network`, `/etc/config/dhcp`, `/etc/config/firewall`

## Recommended candidate posture

- Use Fake-IP, not Redir-Host.
- Keep fallback empty by default.
- Use `system` or verified local/WAN upstreams as nameserver.
- Preserve LAN/private DIRECT rules first.
- Add BT/PT tracker DIRECT rules before general proxy rules.
- Add AI/GitHub rules only after group mapping.
- Keep `MATCH` last.
- Skip deprecated ad-block snippets and unverifiable subscription-conversion services.

## Manual-only items

List these for the user instead of changing them by SSH:

- OpenClash running mode switches in LuCI.
- DNS redirection / Dnsmasq system settings.
- WAN DNS, IPv6, LAN DHCP, and firewall settings.
- SmartDNS/MosDNS/AdGuardHome architecture changes.
- ad-block-fast or other ad-block plugins.

## Safe command pattern

```sh
TARGET_FILE="/etc/openclash/config/config-a(2).yaml"
sh scripts/openclash_multisub_audit.sh
sh scripts/openclash_subscription_binding_audit.sh
TARGET_FILE="$TARGET_FILE" sh scripts/openclash_single_config_template_guard.sh
TARGET_FILE="$TARGET_FILE" sh scripts/openclash_aethersailor_legacy_audit.sh
sh scripts/openclash_aethersailor_remote_audit.sh
python3 scripts/openclash_template_apply.py \
  --target "$TARGET_FILE" \
  --template aethersailor-current-safe \
  --candidate /tmp/config-a2.aethersailor-current-safe.candidate.yaml
python3 scripts/openclash_lint_config.py /tmp/config-a2.aethersailor-current-safe.candidate.yaml
```

Do not apply until the user approves the candidate and rollback path.
