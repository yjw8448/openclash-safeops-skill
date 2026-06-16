# Usage Examples

## Example 1: Read-only diagnosis

```sh
sh scripts/openclash_diagnose.sh
```

## Example 2: Backup before a candidate workflow

```sh
sh scripts/openclash_backup.sh
```

## Example 3: DNS audit

```sh
sh scripts/openclash_dns_audit.sh
```

## Example 4: Multi-subscription guard

```sh
sh scripts/openclash_multisub_audit.sh
sh scripts/openclash_subscription_binding_audit.sh
```

## Example 5: Generate Aethersailor current-safe candidate

```sh
TARGET_FILE=/etc/openclash/config/provider-a.yaml   sh scripts/openclash_single_config_template_guard.sh

python3 scripts/openclash_template_apply.py   --target /etc/openclash/config/provider-a.yaml   --template aethersailor-current-safe   --candidate /tmp/provider-a.safeops.candidate.yaml
```

## Example 6: Validate candidate

```sh
python3 scripts/openclash_lint_config.py /tmp/provider-a.safeops.candidate.yaml
python3 scripts/openclash_group_detect.py /tmp/provider-a.safeops.candidate.yaml --env
```

## Example 7: Apply after explicit approval

```sh
I_UNDERSTAND_TARGETED_WRITE=1 python3 scripts/openclash_template_apply.py   --target /etc/openclash/config/provider-a.yaml   --template aethersailor-current-safe   --candidate /tmp/provider-a.safeops.candidate.yaml   --apply
```

## Example 8: Emergency restore when SSH still works

```sh
I_UNDERSTAND_SAFEOPS_WRITE=1 sh scripts/openclash_emergency_restore.sh --apply
```

## Example 9: Generate a redacted report

```sh
python3 scripts/openclash_report_writer.py --output-dir . --stdin-notes
```

## Example 10: Local SSH helper hygiene

Do not paste raw subscription URLs, passwords, tokens, or dashboard secrets into shared logs. Run diagnostics, redact output, and then share the generated report.
