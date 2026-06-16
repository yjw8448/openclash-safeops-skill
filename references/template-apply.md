# Single-config template application

Use this reference when the user asks to modify the current OpenClash config or a specific YAML config according to a template, for example:

- `把 config-a(2).yaml 按 FFAni 方案设置`
- `把当前配置按照模板改一下`
- `只改这个配置，不要影响另一个订阅`

## Goal

Apply one template profile to exactly one existing YAML config while preserving subscription boundaries.

```text
one selected target YAML -> one candidate YAML -> user approval -> one target overwrite
```

## Non-goals

Do not perform global one-click setup. Do not merge multiple subscriptions. Do not overwrite all YAML files. Do not modify OpenWrt network/dhcp/firewall.

## Required preflight

1. Identify the exact target file.
2. Run multi-subscription and binding audits.
3. Run the single-config guard.
4. Back up `/etc/config/openclash` and `/etc/openclash/`.
5. Check whether the chosen template has external prerequisites.

Example:

```sh
TARGET_FILE="/etc/openclash/config/config-a(2).yaml"
sh scripts/openclash_multisub_audit.sh
sh scripts/openclash_subscription_binding_audit.sh
TARGET_FILE="$TARGET_FILE" sh scripts/openclash_single_config_template_guard.sh
sh scripts/openclash_backup.sh
```

## Candidate workflow

Generate a candidate instead of editing the target directly:

```sh
TARGET_FILE="/etc/openclash/config/config-a(2).yaml"
CANDIDATE="/tmp/config-a2.ffani.candidate.yaml"
python3 scripts/openclash_template_apply.py \
  --target "$TARGET_FILE" \
  --template ffani-redirhost-smartdns \
  --candidate "$CANDIDATE"
python3 scripts/openclash_lint_config.py "$CANDIDATE"
python3 scripts/openclash_group_detect.py "$CANDIDATE"
```

Report the diff summary and wait for approval.

## Apply workflow

Apply only after explicit approval:

```sh
I_UNDERSTAND_TARGETED_WRITE=1 python3 scripts/openclash_template_apply.py \
  --target "$TARGET_FILE" \
  --template ffani-redirhost-smartdns \
  --candidate "$CANDIDATE" \
  --apply
```

## Built-in templates

These names must match `scripts/openclash_template_apply.py --template` choices.

| Template | Purpose | Notes |
|---|---|---|
| `aethersailor-current-safe` | Current Aethersailor-style Fake-IP/DNS/sniffer/rule candidate for one existing config. | Preferred for new Aethersailor requests. Read `references/aethersailor-current-safe.md`; audit remote dependencies before adding external rule-providers. |
| `aethersailor-legacy-safe` | Backward-compatible Aethersailor-style candidate for older prompts. | Avoid deprecated ad snippets and unverifiable conversion services; prefer `aethersailor-current-safe` for new work. |
| `ffani-redirhost-smartdns` | Redir-Host + SmartDNS style DNS/sniffer/BT-PT direct candidate for one config. | Requires SmartDNS audit; do not use if ports 6053/6553 are absent unless creating a staged candidate only. |
| `minimal-safe` | Minimal DNS/sniffer defaults for one config. | Lower risk baseline for recently broken routers. |
| `ai-dev-rules` | AI/GitHub/developer rules for one config. | Requires real group names; use `--ai-group` and `--proxy-group` when detection is uncertain. |

## Overlay file mode

Use a custom safe overlay only when it avoids protected sections:

```sh
python3 scripts/openclash_template_apply.py \
  --target "$TARGET_FILE" \
  --overlay-file templates/ffani-redirhost-smartdns-overlay.yaml \
  --candidate "$CANDIDATE"
```

Protected sections are refused:

```text
proxies
Proxy
proxy-groups
proxy-providers
proxy-provider
```

## FFAni-style profile prerequisites

Before applying `ffani-redirhost-smartdns`, check:

```sh
/etc/init.d/smartdns status 2>/dev/null || true
netstat -lntup 2>/dev/null | grep -E ':53|:6053|:6553|:7874|:7890|:7891|:9090' || true
```

If SmartDNS is missing or 6053/6553 are not listening, do not overwrite the target. Generate a candidate and report that LuCI/SmartDNS prerequisites are not met.

## Required report

Report:

1. Target YAML.
2. Template profile.
3. Subscription binding status.
4. Backup directory.
5. Candidate path.
6. Modified YAML sections.
7. Protected sections preserved.
8. Lint/group detection result.
9. Diff summary.
10. Exact rollback command.
11. Whether user approval is required before overwrite.
