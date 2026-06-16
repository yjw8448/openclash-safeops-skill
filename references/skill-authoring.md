# Skill Authoring Notes

This repository is both an OpenClash operations toolkit and an AI Agent Skill package. Keep the packaging predictable so WorkBuddy, OpenClaw, Claude-compatible, and MCP-style agents can load it consistently.

## Required structure

A valid Skill package must include:

```text
openclash-safeops/
├── SKILL.md
├── scripts/
├── references/
└── docs/kb/
```

`SKILL.md` must begin with YAML frontmatter:

```yaml
---
name: openclash-safeops
description: SSH-based safe diagnosis and repair for OpenClash on OpenWrt. Use when the user needs OpenClash help without modifying OpenWrt network, DHCP, or firewall system configs.
---
```

## Frontmatter rules

- `name` must be lowercase and hyphenated.
- `description` must explain what the Skill does and when to use it.
- Keep metadata concise.
- Do not store secrets, router IPs, subscription URLs, dashboard paths, or credentials in frontmatter.
- If optional metadata such as `version` is used, quote it as a string.

## Progressive disclosure

Keep `SKILL.md` runtime-critical. Put long details in:

- `references/` for runtime reference documents.
- `docs/kb/` for knowledge-base and decision-tree material.
- `scripts/` for deterministic operations.
- `templates/` for YAML overlays and rule snippets.

Agents should load only the references needed for the current workflow.

## SafeOps-specific authoring rules

- Safety boundaries belong in `SKILL.md` because they must always be visible when the Skill activates.
- Long explanations of why a rule exists belong in `docs/kb/`.
- Exact command usage belongs in `references/scripts-reference.md` or the script help text.
- External website summaries belong in `references/upstream-sources.md` and `docs/kb/source-map.md`.
- External website content must never be fetched and executed at runtime.

## Style rules

- Do not compress Markdown into one-line paragraphs.
- Use short sections and explicit headings.
- Prefer fenced code blocks for commands.
- Use generic placeholders such as `config-a.yaml`, `provider-a.yaml`, and `192.168.1.1` only as examples.
- Do not include real subscription URLs, passwords, or tokens in examples.

## Release packaging checklist

Before packaging a release:

1. Validate `SKILL.md` frontmatter.
2. Remove `__pycache__/` and Python bytecode.
3. Run Python compile checks.
4. Lint YAML templates.
5. Check that README directory descriptions do not contain stale hard-coded counts.
6. Confirm `references/changelog.md` has newest version at the top.
7. Confirm new references are linked from `SKILL.md` or `references/document-index.md` if they are runtime-relevant.
8. Confirm safety rules still prohibit normal edits to OpenWrt network, DHCP, and firewall configs.
