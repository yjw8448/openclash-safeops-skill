---
name: openclash-safeops
version: 7.3
agent_created: true
description: This skill should be used when the user needs SSH-based diagnosis, emergency recovery, safe repair, DNS auditing, subscription management, multi-subscription protection, no-subscription-info recovery, targeted one-config template application, Aethersailor current-safe candidate generation, one-click profile dry-runs, or rule setup for OpenClash on OpenWrt.
---

# OpenClash SafeOps Skill v7.3 - Aethersailor Reference Fix and Lean Runtime

## Purpose

Operate OpenClash on OpenWrt safely. Preserve SSH, LuCI, DHCP, DNS, LAN routing, subscription-to-config mappings, target YAML boundaries, and rollback ability before starting or reconfiguring OpenClash.

Use candidate generation by default. Treat router-wide network edits, multi-subscription merges, and unbound YAML writes as escalation cases.

## Absolute safety rules

1. Start with read-only diagnosis unless the user explicitly asks for repair or template generation.
2. Never modify `/etc/config/network`, `/etc/config/dhcp`, `/etc/config/firewall`, LAN IP, DHCP, WAN/LAN interfaces, `br-lan`, Wi-Fi, or firewall zones during normal OpenClash repair or template application.
3. Never run `firstboot`, `sysupgrade`, `reboot`, `wifi down`, `/etc/init.d/network restart`, `uci commit network`, `uci commit firewall`, or mass firewall flush commands unless the user approves after a risk warning.
4. Back up `/etc/config/openclash` and `/etc/openclash/` before any write. Back up network/dhcp/firewall for rollback visibility only; do not modify them.
5. Start the watchdog before medium-risk OpenClash writes.
6. Mask subscription URLs, proxy credentials, dashboard secrets, tokens, and passwords in all output.
7. Stop and ask when the current router IP, active config, subscription mapping, target YAML, template profile, candidate path, or rollback path is unclear.

## Highest-priority guards

### Single-config template guard

When the user asks to modify a current/specific YAML according to a template, enter Template mode. Require exactly one target file and preserve this invariant:

```text
one template profile -> one candidate YAML -> user approval -> one target YAML overwrite
```

Run `openclash_multisub_audit.sh`, `openclash_subscription_binding_audit.sh`, and `openclash_single_config_template_guard.sh` before candidate generation. Generate a candidate with `openclash_template_apply.py`; do not write back unless the user approves and `I_UNDERSTAND_TARGETED_WRITE=1` is set. Read `references/template-apply.md` for details.

### Multi-subscription guard

When multiple subscriptions, multiple YAML files, unbound YAML files, or unknown subscription-to-config mappings are detected, stop normal repair. Do not merge subscriptions, overwrite YAML files, or convert two configs into one `merged.yaml`/`pqjc.yaml`.

Run:

```sh
sh scripts/openclash_multisub_audit.sh
python3 scripts/openclash_config_fingerprint.py /etc/openclash/config/*.yaml /etc/openclash/config/*.yml
sh scripts/openclash_multisub_guard.sh
```

Preserve this invariant unless the user explicitly approves a merge plan:

```text
Subscription A -> Config A.yaml
Subscription B -> Config B.yaml
```

### No-subscription-info guard

When LuCI shows `无订阅信息` / no subscription information for a YAML such as `pqjc.yaml`, treat it as unbound. Do not update it as a normal subscription-managed config. First preserve it, audit binding records, and classify it as local, generated, restored, or accidentally merged.

Run:

```sh
sh scripts/openclash_no_subinfo_audit.sh
sh scripts/openclash_subscription_binding_audit.sh
sh scripts/openclash_quarantine_unbound_config.sh /etc/openclash/config/pqjc.yaml
```

Use quarantine `--apply` only after backup and user approval.

### Aethersailor Current-Safe guard

When the user asks for `Aethersailor/Custom_OpenClash_Rules` or `yjw8448/Aethersailor-Custom_OpenClash_Rules`, treat the repo as a source snapshot and design guide, not an installer. Prefer `aethersailor-current-safe` for new work and `aethersailor-legacy-safe` only for backward-compatible prompts.

Apply only to one target YAML by generating a local candidate. Keep Aethersailor system-level requirements, DNS redirection, WAN/LAN/IPv6 settings, firewall zones, abandoned ad snippets, and unverifiable remote rules as manual checks. Do not modify OpenWrt system configs.

Required reading before writing:

```text
references/aethersailor-current-safe.md
references/aethersailor-source-snapshot.md
references/template-apply.md
```

Required pattern:

```sh
TARGET_FILE="/etc/openclash/config/example.yaml"
sh scripts/openclash_multisub_audit.sh
sh scripts/openclash_subscription_binding_audit.sh
TARGET_FILE="$TARGET_FILE" sh scripts/openclash_single_config_template_guard.sh
TARGET_FILE="$TARGET_FILE" sh scripts/openclash_aethersailor_legacy_audit.sh
sh scripts/openclash_aethersailor_remote_audit.sh
python3 scripts/openclash_template_apply.py --target "$TARGET_FILE" --template aethersailor-current-safe --candidate /tmp/example.aethersailor-current-safe.candidate.yaml
python3 scripts/openclash_lint_config.py /tmp/example.aethersailor-current-safe.candidate.yaml
```

## Runtime modes

- Plan mode: Explain the plan, risk, commands, and rollback. Do not execute.
- Diagnose mode: Run or provide read-only checks. Report evidence and next options.
- Emergency mode: Restore basic connectivity when OpenClash breaks internet/DNS/LuCI but SSH works.
- Repair mode: Apply scoped OpenClash fixes after backup; use watchdog for medium-risk changes.
- Configure mode: Generate or apply a reversible OpenClash profile; default to dry-run.
- Template mode: Modify exactly one existing YAML by creating a candidate first. Use `aethersailor-current-safe` for current Aethersailor-style Fake-IP/DNS/rule candidate generation.
- Rule mode: Generate rules only after detecting real strategy-group names.
- Binding recovery mode: Recover subscription-to-config mappings before any normal subscription update.

## Required output format

For every diagnosis, repair, or template application, report: judgment, risk level, target YAML, template profile, multi-subscription/unbound status, candidate path, changed files, backup path, rollback command, and verification result. Use `references/output-format.md` for the full checklist.

## Standard workflow

1. Classify the scenario: lockout, DNS failure, subscription failure, YAML error, rule mismatch, single-config template application, multi-subscription problem, or no-subscription-info config.
2. Read `references/document-index.md` and only the relevant scenario documents.
3. Run read-only diagnosis first: `sh scripts/openclash_diagnose.sh`.
4. For one-target template work, read `references/template-apply.md`; for Aethersailor, also read `references/aethersailor-current-safe.md` and `references/aethersailor-source-snapshot.md`.
5. Stop normal repair if multiple configs/subscriptions or `无订阅信息` appear.
6. If connectivity is broken but SSH works, run emergency mode: `sh scripts/openclash_emergency_restore.sh --apply`.
7. Audit subscriptions, DNS, YAML, and group names as needed with the relevant scripts in `references/scripts-reference.md`.
8. Back up before writes: `sh scripts/openclash_backup.sh`.
9. Start watchdog before medium-risk writes.
10. Verify connectivity and OpenClash state before disarming watchdog.

## Script, template, and reference index

Read these selectively:

- Full document map: `references/document-index.md`.
- Script arguments and risk levels: `references/scripts-reference.md`.
- Single-config template application: `references/template-apply.md`.
- Aethersailor current-safe generation: `references/aethersailor-current-safe.md`.
- Aethersailor source snapshot and Custom_Clash.ini extraction: `references/aethersailor-source-snapshot.md`.
- Aethersailor legacy compatibility: `references/aethersailor-legacy-safe.md`.
- Template files and one-click assets: `references/templates-reference.md` and `templates/`.
- Output format details: `references/output-format.md`.
- Baseline reference sources: `references/baseline-profiles.md`.
- One-click profiles: `references/profiles.md`.
- Rule design: `references/rule-design.md`.
- Common repairs: `references/common-repairs.md`.
- Official Wiki mapping: `references/wiki-mapping.md`.
- Version history: `references/changelog.md`.

## Escalation rules

Stop and ask the user before proceeding when SSH/LuCI may be lost, the target YAML or active config is unclear, mappings are unproven, LuCI shows `无订阅信息`, a template would touch protected sections or another YAML, a backup cannot be verified, or any fix requires network/dhcp/firewall edits, network restart, reboot, reset, or firmware upgrade.
