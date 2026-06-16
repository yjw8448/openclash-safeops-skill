---
name: openclash-safeops
version: 7.6
agent_created: true
description: This skill should be used when the user needs SSH-based diagnosis, emergency recovery, safe repair, DNS auditing, subscription management, active config/update URL binding checks, report generation, multi-subscription protection, no-subscription-info recovery, single-config template application, Aethersailor current-safe candidate generation, one-click profile templates, or rule setup for OpenClash on OpenWrt.
---

# OpenClash SafeOps Skill v7.6

## Purpose

Operate OpenClash on OpenWrt safely. Preserve SSH, LuCI, DHCP, DNS, LAN routing, subscription-to-config mappings, active-config/update-URL consistency, and rollback ability before trying to start or reconfigure OpenClash.

Use this skill for OpenClash diagnosis, emergency recovery, safe repair, report generation, binding audits, single-config template application, Aethersailor current-safe candidate generation, DNS conflict audits, subscription health checks, rule generation, multi-subscription protection, and recovery of YAML files that show `无订阅信息` / no subscription information.

## Absolute safety rules

1. Start with read-only diagnosis unless the user explicitly asks for repair.
2. Never modify `/etc/config/network`, `/etc/config/dhcp`, `/etc/config/firewall`, LAN IP, DHCP, WAN/LAN interfaces, `br-lan`, Wi-Fi, or firewall zones during normal OpenClash repair or template application.
3. Never run `firstboot`, `sysupgrade`, `reboot`, `wifi down`, `/etc/init.d/network restart`, `uci commit network`, `uci commit dhcp`, `uci commit firewall`, or mass firewall flush commands unless the user explicitly approves after a risk warning.
4. Back up `/etc/config/openclash` and `/etc/openclash/` before any write. Back up network/dhcp/firewall for rollback visibility only; do not modify them.
5. Mask subscription URLs, proxy credentials, dashboard secrets, tokens, API keys, passwords, Bearer tokens, and dashboard API paths in every command output and report.
6. Stop and ask when the current router IP, active config, `config_update_url`, subscription mapping, target file, template profile, or rollback path is unclear.

## Highest-priority guards

### Active config / update URL binding guard

When selecting a YAML such as `config-a(2).yaml` causes OpenClash to switch back to another provider such as `config-b.yaml`, stop ordinary repair and run:

```sh
sh scripts/openclash_active_binding_audit.sh
```

If `config_path`, `config_update_url`, and `auto_update` are inconsistent, ask which provider should be the current auto-update target. Do not blindly set `config_update_url`, and never print the raw URL. Read `docs/kb/82-active-config-update-url-binding.md` before proposing a fix.

### Report generation guard

Every diagnosis, repair, binding audit, or template workflow must finish by generating both:

```text
openclash_fix_report.md
openclash_fix_report_YYYYmmdd-HHMMSS.md
```

Use:

```sh
python3 scripts/openclash_report_writer.py --output-dir . --stdin-notes
```

All report content must pass the unified redaction logic in `scripts/openclash_redact.py`. Read `references/reporting.md` for the full workflow.

### Single-config template apply guard

When the user asks to modify the current config or a specific config according to a template, treat it as targeted template application, not global one-click configuration. Require one explicit target file. Generate one candidate file. Lint it. Ask before writing back.

Invariant:

```text
Template profile -> one candidate file -> one user-approved target file
```

Common pattern:

```sh
TARGET_FILE="/etc/openclash/config/example.yaml"
sh scripts/openclash_multisub_audit.sh
sh scripts/openclash_subscription_binding_audit.sh
TARGET_FILE="$TARGET_FILE" sh scripts/openclash_single_config_template_guard.sh
python3 scripts/openclash_template_apply.py --target "$TARGET_FILE" --template aethersailor-current-safe --candidate /tmp/example.candidate.yaml
python3 scripts/openclash_lint_config.py /tmp/example.candidate.yaml
```

Write back only after user approval:

```sh
I_UNDERSTAND_TARGETED_WRITE=1 python3 scripts/openclash_template_apply.py --target "$TARGET_FILE" --template aethersailor-current-safe --candidate /tmp/example.candidate.yaml --apply
```

### Multi-subscription guard

When multiple subscriptions, multiple YAML files, unbound YAML files, or unknown config-to-subscription mappings are detected, stop normal repair.

Do not merge subscriptions. Do not overwrite YAML files. Do not convert two subscription-managed configs into one `merged.yaml` or one `config-a.yaml`. Preserve:

```text
Subscription A -> Config A.yaml
Subscription B -> Config B.yaml
```

Run multi-subscription and fingerprint audits before any write:

```sh
sh scripts/openclash_multisub_audit.sh
python3 scripts/openclash_config_fingerprint.py /etc/openclash/config/*.yaml /etc/openclash/config/*.yml
sh scripts/openclash_multisub_guard.sh
```

### No-subscription-info guard

When LuCI shows a config such as `config-a.yaml` with `无订阅信息` / no subscription information, treat it as an unbound config. Do not update it as a normal subscription-managed config. Preserve it, audit bindings, and identify whether it is local, generated, restored, or accidentally merged.

```sh
sh scripts/openclash_no_subinfo_audit.sh
sh scripts/openclash_subscription_binding_audit.sh
sh scripts/openclash_quarantine_unbound_config.sh /etc/openclash/config/config-a.yaml
```

Use `--apply` only after backup and user approval.

### Aethersailor Current-Safe adapter guard

When the user asks to configure one YAML according to `Aethersailor/Custom_OpenClash_Rules` or a maintained fork, treat the repository as a design guide, not as a blindly executable installer. Generate a local candidate for exactly one target YAML. Do not modify OpenWrt system configs, DNS redirection, WAN/LAN/IPv6 settings, firewall zones, abandoned ad scripts, or unverifiable remote dependencies.

Read `references/aethersailor-current-safe.md` and `references/aethersailor-source-snapshot.md`. Use `aethersailor-current-safe` as the preferred template and keep `aethersailor-legacy-safe` only for backward compatibility.

## Runtime modes

- Plan mode: Explain the plan, risk, commands, and rollback. Do not execute.
- Diagnose mode: Run or provide read-only checks. Report evidence and next options.
- Emergency mode: Restore basic connectivity when OpenClash breaks internet/DNS/LuCI but SSH works.
- Repair mode: Apply scoped fixes after backup; use watchdog for medium-risk changes.
- Configure mode: Generate or apply a reversible OpenClash profile; default to dry-run.
- Template mode: Modify exactly one existing YAML config according to a chosen template by creating a candidate first.
- Binding recovery mode: Recover subscription-to-config and active-config/update-URL mappings before any normal subscription update.
- Reporting mode: Refresh `openclash_fix_report.md` and create a timestamped snapshot with redacted content.

## Required output format

For every workflow, report the judgment, risk level, target config, active config/update-URL consistency, multi-subscription/unbound-config status, candidate file, files changed, backup/rollback details, report paths, and verification result. Use `references/output-format.md` for the full checklist.

## Standard workflow

1. Identify the scenario: lockout, DNS failure, subscription failure, YAML error, rule mismatch, single-config template application, active-config auto-switch, stale report, multi-subscription problem, or no-subscription-info config.
2. Read `references/document-index.md` and the relevant reference before acting.
3. Run read-only diagnosis first:
   ```sh
   sh scripts/openclash_diagnose.sh
   ```
4. If a selected config switches back to another config, run `scripts/openclash_active_binding_audit.sh` and stop until the user chooses the intended current auto-update target.
5. If the user asks to apply a template to one config, enter Template mode and read `references/template-apply.md`. For Aethersailor, also read `references/aethersailor-current-safe.md` and `references/aethersailor-source-snapshot.md`.
6. If multiple configs/subscriptions or `无订阅信息` appear, run the corresponding highest-priority guard and stop normal repair.
7. If connectivity is broken but SSH works, use emergency mode:
   ```sh
   sh scripts/openclash_emergency_restore.sh --apply
   ```
8. If subscription update fails, audit subscription health:
   ```sh
   sh scripts/openclash_subscription_health.sh
   ```
9. If DNS is suspicious, audit DNS conflicts:
   ```sh
   sh scripts/openclash_dns_audit.sh
   ```
10. If YAML or rules are suspicious, lint config and detect groups:
    ```sh
    python3 scripts/openclash_lint_config.py /etc/openclash/config/*.yaml
    python3 scripts/openclash_group_detect.py /etc/openclash/config/*.yaml --env
    ```
11. Back up before writes:
    ```sh
    sh scripts/openclash_backup.sh
    ```
12. Verify after changes and generate a redacted report:
    ```sh
    sh scripts/openclash_verify_connectivity.sh
    python3 scripts/openclash_report_writer.py --output-dir . --stdin-notes
    ```

## Script and template references

Read `references/scripts-reference.md` before using unfamiliar scripts. For targeted template application, read `references/template-apply.md`. For one-click profiles, overwrite snippets, group-map examples, and rule templates, read `references/templates-reference.md` and the `templates/` directory.

## Reference index

Use these references selectively instead of loading every document:

- Full document map: `references/document-index.md`.
- Script arguments and risk levels: `references/scripts-reference.md`.
- Report generation and redaction: `references/reporting.md`, `docs/kb/81-report-generation-and-sync.md`.
- Active config/update URL binding: `docs/kb/82-active-config-update-url-binding.md`.
- Local SSH helper hygiene: `docs/kb/83-local-ssh-helper-hygiene.md`.
- Single-config template application: `references/template-apply.md`.
- Aethersailor current-safe candidate generation: `references/aethersailor-current-safe.md`.
- Aethersailor source snapshot: `references/aethersailor-source-snapshot.md`.
- Aethersailor legacy-safe compatibility: `references/aethersailor-legacy-safe.md`.
- Template files and one-click assets: `references/templates-reference.md` and `templates/`.
- Output format details: `references/output-format.md`.
- Baseline reference sources: `references/baseline-profiles.md`.
- One-click profiles: `references/profiles.md`.
- Rule design: `references/rule-design.md`.
- Common repairs: `references/common-repairs.md`.
- Official Wiki mapping: `references/wiki-mapping.md`.
- Version history: `references/changelog.md`.

## Escalation rules

Stop and ask the user before proceeding when:

- SSH or LuCI may be lost.
- The active config file cannot be identified.
- `config_path` and `config_update_url` appear to belong to different providers.
- The template profile or target YAML file is unclear.
- More than one subscription/config exists and mapping is not proven.
- LuCI shows `无订阅信息` for the active config.
- A template would modify `proxies`, `proxy-groups`, subscription URLs, or another config file.
- A backup directory cannot be created or verified.
- A script proposes changes outside `/etc/config/openclash` or `/etc/openclash/`.
- Any fix would require network/dhcp/firewall edits, network restart, reboot, reset, or firmware upgrade.
