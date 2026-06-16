# Usage examples

Use these examples to invoke OpenClash SafeOps v7 in WorkBuddy or another agent. Keep the user's real subscription URLs, router password, tokens, and dashboard secrets out of visible logs.

## Example 1: Subscription update failure

User says:

```text
我的 OpenClash 更新订阅失败了，SSH 可以进路由器。
```

Expected skill behavior:

1. Run read-only diagnosis first.
2. Check whether multiple subscriptions or unbound configs exist.
3. Audit subscription health.
4. Audit DNS only if subscription fetch depends on DNS.
5. Back up before changing OpenClash settings.
6. Never edit network/dhcp/firewall.

Relevant files:

```text
SKILL.md
references/document-index.md
references/scripts-reference.md
docs/kb/70-subscription-decision-tree.md
scripts/openclash_diagnose.sh
scripts/openclash_subscription_health.sh
```

## Example 2: `pqjc.yaml` shows no subscription information

User says:

```text
OpenClash 页面显示配置文件 pqjc.yaml，更新时间有，但无订阅信息。
```

Expected skill behavior:

1. Stop ordinary subscription repair.
2. Treat `pqjc.yaml` as an unbound YAML.
3. Back up and preserve the file.
4. Audit UCI subscription bindings.
5. Decide whether the file is local, generated, restored, or accidentally merged.
6. Ask before quarantine or restore.

Relevant files:

```text
SKILL.md
docs/kb/76-unbound-config-decision-tree.md
docs/kb/playbooks/no-subscription-info-pqjc.md
scripts/openclash_no_subinfo_audit.sh
scripts/openclash_subscription_binding_audit.sh
scripts/openclash_quarantine_unbound_config.sh
```

## Example 3: Two subscriptions were merged into one config

User says:

```text
我原来是两个订阅对应两个配置，修复后变成一个配置了。
```

Expected skill behavior:

1. Stop normal repair immediately.
2. Back up the current bad merged state.
3. Search SafeOps/OpenClash backups.
4. Fingerprint YAML files.
5. Restore only `/etc/config/openclash` and `/etc/openclash/` from a confirmed backup.
6. Do not restore or edit network/dhcp/firewall.

Relevant files:

```text
SKILL.md
docs/kb/75-multi-subscription-decision-tree.md
docs/kb/playbooks/restore-two-subscriptions.md
scripts/openclash_multisub_audit.sh
scripts/openclash_config_fingerprint.py
scripts/openclash_restore_multiconfig.sh
```

## Example 4: OpenClash enabled and internet broke, but SSH works

User says:

```text
OpenClash 一开就断网，但是 SSH 还能进。
```

Expected skill behavior:

1. Run emergency mode, not normal one-click config.
2. Stop OpenClash and orphaned cores.
3. Restart dnsmasq/uhttpd only.
4. Verify router DNS and external connectivity.
5. Leave OpenClash stopped until diagnosis is complete.

Relevant files:

```text
SKILL.md
docs/kb/playbooks/emergency-restore.md
scripts/openclash_emergency_restore.sh
scripts/openclash_verify_connectivity.sh
```

## Example 5: Generate a safe one-click profile

User says:

```text
帮我生成一个 OpenClash 的安全一键配置模板，不要直接改路由器。
```

Expected skill behavior:

1. Use Configure mode.
2. Default to dry-run.
3. Use the templates directory and `references/templates-reference.md`.
4. Detect real strategy-group names before writing rules.
5. Apply only after backup and multi-subscription guard passes.

Relevant files:

```text
references/templates-reference.md
references/profiles.md
templates/oneclick-profile.env.example
templates/overwrite-safe-basic.yaml
templates/overwrite-ai-dev.yaml
templates/rules-ai-classical.yaml
scripts/openclash_oneclick_config.sh
scripts/openclash_multisub_guard.sh
```

## Example 6: Apply a template to one current config

User says:

```text
我想把 pqjc(2).yaml 按 FFAni 的 Redir-Host + SmartDNS 模板改一下，只改这个配置。
```

Expected skill behavior:

1. Enter Template mode, not one-click global configuration.
2. Confirm the exact target file `/etc/openclash/config/pqjc(2).yaml`.
3. Run multi-subscription and binding audits first.
4. Run the single-config template guard.
5. Verify SmartDNS prerequisites before using the FFAni profile.
6. Generate a candidate YAML under `/tmp`, lint it, and show a diff.
7. Preserve `proxies`, `proxy-groups`, and subscription binding.
8. Ask for approval before overwriting the target file.

Relevant files:

```text
SKILL.md
references/template-apply.md
references/templates-reference.md
docs/kb/77-single-config-template-apply.md
templates/ffani-redirhost-smartdns-overlay.yaml
scripts/openclash_single_config_template_guard.sh
scripts/openclash_template_apply.py
scripts/openclash_lint_config.py
```

## Example 7: Generate one config using Aethersailor Legacy-Safe

User says:

> Use the Aethersailor-Custom_OpenClash_Rules style to generate a candidate config for `/etc/openclash/config/pqjc(2).yaml`. Do not modify other YAML files, do not merge subscriptions, and do not modify network/dhcp/firewall.

Expected skill route:

1. Enter Template mode.
2. Enter Aethersailor Legacy-Safe adapter guard.
3. Audit multi-subscription and binding status.
4. Run `openclash_aethersailor_legacy_audit.sh`.
5. Generate candidate with `openclash_template_apply.py --template aethersailor-legacy-safe`.
6. Lint candidate and report diff.
7. Wait for explicit user approval before writing back.

Example commands:

```sh
TARGET_FILE="/etc/openclash/config/pqjc(2).yaml"
sh scripts/openclash_multisub_audit.sh
sh scripts/openclash_subscription_binding_audit.sh
TARGET_FILE="$TARGET_FILE" sh scripts/openclash_single_config_template_guard.sh
TARGET_FILE="$TARGET_FILE" sh scripts/openclash_aethersailor_legacy_audit.sh
python3 scripts/openclash_template_apply.py \
  --target "$TARGET_FILE" \
  --template aethersailor-legacy-safe \
  --candidate /tmp/pqjc2.aethersailor-legacy-safe.candidate.yaml
python3 scripts/openclash_lint_config.py /tmp/pqjc2.aethersailor-legacy-safe.candidate.yaml
```

## Example 8: Generate one config using Aethersailor Current-Safe

User says:

> 按 yjw8448/Aethersailor-Custom_OpenClash_Rules 的最新思路，给 `/etc/openclash/config/pqjc(2).yaml` 生成候选配置。不要覆盖原文件，不要改系统配置，不要合并订阅。

Expected skill behavior:

1. Enter Template mode.
2. Enter Aethersailor Current-Safe adapter guard.
3. Read `references/aethersailor-current-safe.md` and `references/aethersailor-source-snapshot.md`.
4. Audit multi-subscription and binding state.
5. Audit remote dependencies with `openclash_aethersailor_remote_audit.sh`, but default to local templates if anything is unsafe.
6. Generate candidate only:

```sh
TARGET_FILE="/etc/openclash/config/pqjc(2).yaml"
python3 scripts/openclash_template_apply.py \
  --target "$TARGET_FILE" \
  --template aethersailor-current-safe \
  --candidate /tmp/pqjc2.aethersailor-current-safe.candidate.yaml
```

Relevant files:

```text
references/aethersailor-current-safe.md
references/aethersailor-source-snapshot.md
docs/kb/79-aethersailor-current-safe-config-generation.md
scripts/openclash_aethersailor_remote_audit.sh
scripts/openclash_template_apply.py
templates/aethersailor-current-safe-overlay.yaml
```
