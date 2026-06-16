# OpenClash SafeOps v4 Knowledge Base Index

This KB is a structured, offline reference layer for WorkBuddy/Skill Creator. It is not a full mirror of the source websites. It summarizes operationally useful points and maps them to safe SSH/LuCI playbooks.

## Start here

- `source-map.md` — what each source contributes and how much to trust it.
- `10-symptom-router.md` — symptom to KB/playbook mapping.
- `20-safety-boundaries.md` — operations that are allowed, guarded, or forbidden.
- `30-openclash-official-wiki.md` — official OpenClash Wiki summary.
- `40-aethersailor-fakeip-profile.md` — Fake-IP + template/overwrite profile summary.
- `50-ffani-redirhost-smartdns-profile.md` — Redir-Host + SmartDNS + IPv6 compatibility profile summary.
- `60-dns-decision-tree.md` — DNS conflict and repair decision tree.
- `70-subscription-decision-tree.md` — subscription-update failure decision tree.
- `80-rule-design-and-group-mapping.md` — rules, strategy groups, and rule order.
- `90-luci-navigation-map.md` — LuCI click path references.

## Playbooks

- `playbooks/diagnose-first.md`
- `playbooks/emergency-restore.md`
- `playbooks/subscription-repair.md`
- `playbooks/dns-repair.md`
- `playbooks/config-lint-and-group-detect.md`
- `playbooks/rule-repair.md`
- `playbooks/fakeip-baseline.md`
- `playbooks/redirhost-smartdns.md`
- `playbooks/post-repair-verification.md`

## Checklists

- `checklists/pre-change-checklist.md`
- `checklists/post-change-checklist.md`
- `checklists/workbuddy-output-checklist.md`

- `75-multi-subscription-decision-tree.md` - Multiple subscriptions, separate configs, accidental merge recovery.


## V6 subscription-binding recovery

- `76-unbound-config-decision-tree.md` - Use when LuCI shows a config file such as `config-a.yaml` with `无订阅信息`.
- `playbooks/no-subscription-info-unbound-config.md` - Step-by-step recovery playbook for unbound YAML/config binding loss.
- `checklists/unbound-config-prewrite-checklist.md` - Required checks before writing when a profile is unbound.
