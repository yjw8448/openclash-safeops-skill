# Changelog

## v7.7 - Reference Hardening and Skill Packaging Edition

- Fixed `SKILL.md` frontmatter into valid multi-line YAML so agent skill loaders can parse metadata reliably.
- Re-formatted `SKILL.md`, `README.md`, `.gitignore`, `references/changelog.md`, and `docs/kb/source-map.md` from compressed long lines into maintainable Markdown.
- Added upstream reference hardening policy: upstream websites are reference sources only, not runtime-executed instructions.
- Added `references/upstream-sources.md` to classify official and community sources by authority level, safe use, and SafeOps translation.
- Added `references/skill-authoring.md` to document Skill packaging, frontmatter, progressive disclosure, and repository hygiene.
- Added `docs/kb/31-openwrt-operational-safety.md` for OpenWrt-layer safety, failsafe boundary, SSH/LuCI recovery limits, and system-config no-touch policy.
- Added `docs/kb/32-mihomo-schema-compatibility.md` for Mihomo/OpenClash YAML schema compatibility and version-sensitive DNS field handling.
- Added `docs/kb/84-upstream-reference-refresh-policy.md` for safe upstream documentation refresh.
- Added GitHub Actions CI for bytecode regression checks, Skill frontmatter validation, Python compile checks, and YAML linting.
- Added `.editorconfig`, `.prettierrc`, `.yamllint`, and `tools/check_skill_frontmatter.py`.
- Kept all v7.x safety invariants: no normal network/dhcp/firewall edits, no `network restart`, no reboot/reset, no multi-subscription merge, candidate-before-apply, report redaction, and user approval before write.

## v7.6 - Packaging Cleanup and Changelog Order Fix

- Removed accidental `__pycache__/` and Python bytecode from install and GitHub-ready packages.
- Reordered changelog entries so v7.4 appears between v7.5 and v7.3.
- Added a usage example for auditing reusable local SSH helper scripts without deleting them.
- Fixed SKILL.md frontmatter version tag to 7.6 and simplified subtitle.
- Cleaned redundant .gitignore patterns covered by `*.py[cod]`, `*secret*`, and `*token*`.
- Unified source-map.md version sections under Local Policy Additions.
- Replaced personal identifiers with generic placeholders across files and renamed playbook `no-subscription-info-pqjc` to `no-subscription-info-unbound-config`.

## v7.5 - Redaction Consistency and Lean Reporting Polish

- Fixed report redaction consistency: `openclash_report_writer.py` now uses the same 8-pattern redaction logic as `openclash_redact.py`.
- Kept `SKILL.md` lean by moving detailed report and binding workflows to references/KB documents.
- Added v7.4 KB entries to `docs/kb/source-map.md`.
- Added usage examples for active-config auto-switching and stale report refresh.
- Added an explicit report placeholder note so agents replace placeholders before presenting final reports.
- Clarified active-binding provider checks as heuristics instead of provider-specific logic.

## v7.4 - Report and Binding Consistency Edition

- Added `openclash_report_writer.py` to generate both latest and timestamped reports.
- Added `openclash_redact.py` for consistent URL/password/token redaction.
- Added `openclash_active_binding_audit.sh` to detect `config_path` / `config_update_url` / `auto_update` mismatches that can cause config auto-switching.
- Added reporting and binding KB entries.
- Added local SSH helper hygiene policy: do not delete reusable helper scripts automatically; audit and redact instead.
- Promoted report generation and binding consistency to high-priority guards in `SKILL.md`.

## v7.3 - Aethersailor Reference Index Fix and Lean Runtime

- Fixed `SKILL.md` Reference index: `aethersailor-current-safe` now points to `references/aethersailor-current-safe.md`, not the legacy reference.
- Added `references/aethersailor-source-snapshot.md` and `references/aethersailor-current-safe.md` to the runtime Reference index.
- Slimmed the Aethersailor and Template guard text in `SKILL.md` while preserving required safety invariants.
- Completed `references/template-apply.md` built-in template table so it matches `openclash_template_apply.py --template` choices.
- Normalized `examples/usage-examples.md` numbering to use `Example` consistently.
- Expanded the Aethersailor current-safe KB with preflight, YAML-scope, remote-dependency, and manual-only decision logic.

## v7.2 - Aethersailor Current-Safe Source Snapshot Adapter

- Added `aethersailor-current-safe` as the preferred Aethersailor template profile.
- Added source snapshot reference for `yjw8448/Aethersailor-Custom_OpenClash_Rules` and `Custom_Clash.ini` rule order.
- Added `openclash_aethersailor_remote_audit.sh` to check GitHub/raw/CDN dependency health before writing remote rules.
- Added `templates/aethersailor-current-safe-overlay.yaml` and `docs/kb/79-aethersailor-current-safe-config-generation.md`.
- Expanded template generation to include Aethersailor-style Fake-IP, disabled fallback, private/direct rules, BT/PT tracker direct, ChatGPT/AI/GitHub/group-aware rules, Steam/media categories, and no automatic ad-block snippets.

## v7.1 - Aethersailor Legacy-Safe Config Generator

- Added `aethersailor-legacy-safe` template profile for one-target YAML candidate generation.
- Added read-only Aethersailor Legacy-Safe audit script.
- Added local overlay template that avoids abandoned ad scripts and unverifiable remote subscription-conversion services.
- Added reference guidance to keep system-level OpenWrt settings as manual/LuCI checks instead of automatic SSH writes.

## v7 - Single-Config Template Apply Edition

- Added Template mode for modifying exactly one existing OpenClash YAML config according to a chosen template.
- Added `scripts/openclash_single_config_template_guard.sh` to require an explicit target YAML before any template write.
- Added `scripts/openclash_template_apply.py` to generate a candidate YAML, preserve protected subscription sections, preview diffs, and write only after explicit approval.
- Added `templates/ffani-redirhost-smartdns-overlay.yaml` for FFAni-style Redir-Host + SmartDNS candidate generation.
- Added `references/template-apply.md` and `docs/kb/77-single-config-template-apply.md`.
- Updated `SKILL.md` to prioritize single-config template application before one-click/global configuration.

## v6.3 - Runtime Polish and Script Reference Completion

- Removed README.md from the WorkBuddy install package while keeping it in the GitHub-ready package.
- Completed `references/scripts-reference.md` entries for previously unknown helper scripts.
- Normalized SKILL frontmatter description to the recommended third-person wording.
- Confirmed `.gitignore` covers `__pycache__/`, Python bytecode, `.env`, backups, secrets, tokens, and keys.

## v6.2 - Runtime Dedup and Install Package Cleanup

- Removed duplicate root changelog files in favor of `references/changelog.md`.
- Reduced duplication between `SKILL.md`, `references/scripts-reference.md`, and `references/output-format.md`.
- Added `references/templates-reference.md` and linked `templates/` from the runtime reference index.
- Rewrote `examples/usage-examples.md` as practical trigger examples for v6.2 scenarios.
- Split release packaging into a lean WorkBuddy install package and a GitHub-ready package.

## v6.1 - Lean Runtime Edition

- Slimmed `SKILL.md` to runtime-critical instructions.
- Moved long reference material into `references/`.
- Added `references/document-index.md` and `references/scripts-reference.md`.
- Moved multi-subscription and no-subscription-info guards to the highest-priority section.
- Removed `__pycache__` and Python bytecode files.
- Kept v6 safety behavior: watchdog, emergency restore, DNS audit, subscription health check, multi-subscription guard, config fingerprinting, no-subscription-info audit, binding audit, quarantine, and multi-config restore.

## v6 - Subscription Binding Recovery Edition

- Added unbound config detection for LuCI `无订阅信息` cases.
- Added subscription binding audit and quarantine helpers.

## v5 - Multi-Subscription Guard Edition

- Added multi-subscription isolation and accidental merge recovery.

## v4 - Knowledge-Base Edition

- Added structured knowledge base and source mapping.

## v3 - Anti-Lockout Edition

- Added watchdog, emergency restore, DNS audit, subscription health, and connectivity verification.
