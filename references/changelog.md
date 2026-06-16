# Changelog

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
