---
name: openclash-safeops
version: 6.3
agent_created: true
description: This skill should be used when the user needs SSH-based diagnosis, emergency recovery, safe repair, DNS auditing, subscription management, multi-subscription protection, no-subscription-info recovery, one-click profile templates, or rule setup for OpenClash on OpenWrt.
---

# OpenClash SafeOps Skill v6.3 - Lean Runtime Polish Edition

## Purpose

Operate OpenClash on OpenWrt safely. Preserve SSH, LuCI, DHCP, DNS, LAN routing, subscription-to-config mappings, and rollback ability before trying to start or reconfigure OpenClash.

Use this skill for OpenClash diagnosis, emergency recovery, safe repair, one-click configuration dry-runs, DNS conflict audits, subscription health checks, rule generation, multi-subscription protection, and recovery of YAML files that show `无订阅信息` / no subscription information.

## Absolute safety rules

1. Start with read-only diagnosis unless the user explicitly asks for repair.
2. Never modify `/etc/config/network`, `/etc/config/dhcp`, `/etc/config/firewall`, LAN IP, DHCP, WAN/LAN interfaces, `br-lan`, Wi-Fi, or firewall zones during normal OpenClash repair.
3. Never run `firstboot`, `sysupgrade`, `reboot`, `wifi down`, `/etc/init.d/network restart`, `uci commit network`, `uci commit firewall`, or mass firewall flush commands unless the user explicitly approves after a risk warning.
4. Back up `/etc/config/openclash` and `/etc/openclash/` before any write. Back up network/dhcp/firewall for rollback visibility only; do not modify them.
5. Start the watchdog before medium-risk OpenClash writes.
6. Prefer OpenClash stop/restart, dnsmasq restart, YAML validation, overwrite files, rule-providers, and subscription conversion over direct router-wide network edits.
7. Mask subscription URLs, proxy credentials, dashboard secrets, tokens, and passwords in all output.
8. Stop and ask when the current router IP, active config, subscription mapping, or rollback path is unclear.

## Highest-priority guards

### Multi-subscription guard

When multiple subscriptions, multiple YAML files, unbound YAML files, or unknown config-to-subscription mappings are detected, stop normal repair.

Do not merge subscriptions. Do not overwrite YAML files. Do not convert two subscription-managed configs into one `merged.yaml` or one `pqjc.yaml`. Run multi-subscription and fingerprint audits first:

```sh
sh scripts/openclash_multisub_audit.sh
python3 scripts/openclash_config_fingerprint.py /etc/openclash/config/*.yaml /etc/openclash/config/*.yml
sh scripts/openclash_multisub_guard.sh
```

Preserve this invariant unless the user explicitly asks for a merge and approves a merge plan:

```text
Subscription A -> Config A.yaml
Subscription B -> Config B.yaml
```

### No-subscription-info guard

When LuCI shows a config file such as `pqjc.yaml` with `无订阅信息` / no subscription information, treat it as an unbound config. Do not update it as a normal subscription-managed config. First preserve it, audit subscription bindings, and identify whether it is local, generated, restored, or accidentally merged.

Run:

```sh
sh scripts/openclash_no_subinfo_audit.sh
sh scripts/openclash_subscription_binding_audit.sh
sh scripts/openclash_quarantine_unbound_config.sh /etc/openclash/config/pqjc.yaml
```

Use `--apply` for quarantine only after backing up and only when the user agrees.

## Runtime modes

- Plan mode: Explain the plan, risk, commands, and rollback. Do not execute.
- Diagnose mode: Run or provide read-only checks. Report evidence and next options.
- Emergency mode: Restore basic connectivity when OpenClash breaks internet/DNS/LuCI but SSH works.
- Repair mode: Apply scoped fixes after backup; use watchdog for medium-risk changes.
- Configure mode: Generate or apply a reversible OpenClash profile; default to dry-run.
- Rule mode: Generate rules only after detecting real strategy-group names.
- Binding recovery mode: Recover subscription-to-config mappings before any normal subscription update.

## Required output format

For every diagnosis or repair, report the current judgment, risk level, multi-subscription/unbound-config status, files changed with backup/rollback details, and verification result. Use `references/output-format.md` for the full output checklist.

## Standard workflow

1. Identify the user's scenario: lockout, DNS failure, subscription failure, YAML error, rule mismatch, multi-subscription problem, or no-subscription-info config.
2. Read the relevant reference index entry before acting: `references/document-index.md`.
3. Run read-only diagnosis first:
   ```sh
   sh scripts/openclash_diagnose.sh
   ```
4. If multiple configs/subscriptions or `无订阅信息` appear, switch to the highest-priority guards above and stop normal repair.
5. If connectivity is broken but SSH works, use emergency mode:
   ```sh
   sh scripts/openclash_emergency_restore.sh --apply
   ```
6. If subscription update fails, audit subscription health:
   ```sh
   sh scripts/openclash_subscription_health.sh
   ```
7. If DNS is suspicious, audit DNS conflicts:
   ```sh
   sh scripts/openclash_dns_audit.sh
   ```
8. If YAML or rules are suspicious, lint config and detect groups:
   ```sh
   python3 scripts/openclash_lint_config.py /etc/openclash/config/*.yaml
   python3 scripts/openclash_group_detect.py /etc/openclash/config/*.yaml --env
   ```
9. Back up before writes:
   ```sh
   sh scripts/openclash_backup.sh
   ```
10. Start watchdog before medium-risk writes:
    ```sh
    sh scripts/openclash_watchdog.sh --start /root/openclash-safeops-backup-YYYYmmdd-HHMMSS --timeout 300
    ```
11. Verify before disarming watchdog:
    ```sh
    sh scripts/openclash_verify_connectivity.sh
    sh scripts/openclash_watchdog.sh --disarm
    ```

## Script and template references

Read `references/scripts-reference.md` before using unfamiliar scripts. For one-click profiles, overwrite snippets, group-map examples, and rule templates, read `references/templates-reference.md` and the `templates/` directory.

## Reference index

Use these references selectively instead of loading every document:

- Full document map: `references/document-index.md`.
- Script arguments and risk levels: `references/scripts-reference.md`.
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
- More than one subscription/config exists and mapping is not proven.
- LuCI shows `无订阅信息` for the active config.
- A backup directory cannot be created or verified.
- A script proposes changes outside `/etc/config/openclash` or `/etc/openclash/`.
- Any fix would require network/dhcp/firewall edits, network restart, reboot, reset, or firmware upgrade.
