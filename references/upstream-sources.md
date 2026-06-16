# Upstream Sources

This file records upstream sources that may be used when maintaining OpenClash SafeOps. These sources are not runtime command sources. Treat them as documentation inputs that must be translated into SafeOps-compatible workflows.

## Authority levels

| Level | Meaning | Use |
| --- | --- | --- |
| Highest | Official project documentation for the component being discussed | May determine behavior, terminology, and safe UI-level expectations |
| High | Official specs or docs for Skill packaging and agent behavior | May determine package structure and metadata rules |
| Medium | Maintained community profile or compatibility guide | May inspire optional templates and checklists |
| Low | Forum posts, personal blogs, issue comments | Use only as troubleshooting hints; never as policy |

SafeOps safety boundaries always override upstream suggestions.

## OpenClash official Wiki

Source: `https://github.com/vernesong/OpenClash/wiki`

Authority: highest for OpenClash plugin behavior, LuCI settings, config-file concepts, DNS settings, subscription settings, rules, external controller, and update behavior.

Use for:

- Routing symptoms to the right OpenClash feature area.
- Explaining LuCI options.
- Understanding subscription types and config upload behavior.
- Understanding OpenClash DNS modes and rule categories.

SafeOps translation:

- UI guidance does not grant permission to edit OpenWrt system files.
- Prefer OpenClash settings and read-only UCI inspection.
- Any step touching `/etc/config/network`, `/etc/config/dhcp`, or `/etc/config/firewall` must stop and require explicit user approval.

Do not:

- Blindly copy commands from a page into SSH.
- Assume the user is on the latest OpenClash version.
- Print raw subscription URLs from OpenClash UCI output.

## OpenWrt official documentation

Sources:

- `https://openwrt.org/docs/start`
- `https://openwrt.org/docs/guide-user/base-system/uci`
- `https://openwrt.org/docs/guide-user/troubleshooting/failsafe_and_factory_reset`
- `https://openwrt.org/docs/guide-user/troubleshooting/backup_restore`

Authority: highest for OpenWrt system behavior, UCI semantics, service management, backup/restore, and physical recovery.

Use for:

- Defining the boundary between OpenClash repair and OpenWrt system recovery.
- Explaining failsafe, reset, backup, and restore concepts.
- Knowing when remote repair is unsafe.

SafeOps translation:

- Normal OpenClash repair must not write OpenWrt network, DHCP, or firewall config.
- If SSH is unavailable, remote SafeOps repair is not possible.
- If physical failsafe/reset is needed, provide a manual checklist rather than pretending SSH can fix it.

Do not:

- Run `firstboot`, `sysupgrade`, `mtd`, `jffs2reset`, or reset commands automatically.
- Restart network during normal OpenClash workflows.

## Mihomo / MetaCubeX documentation

Sources:

- `https://wiki.metacubex.one/en/config/`
- `https://wiki.metacubex.one/en/config/dns/`
- `https://wiki.metacubex.one/en/config/rules/`

Authority: highest for Mihomo core YAML schema and DNS/rule behavior.

Use for:

- Validating YAML fields used by SafeOps templates.
- Checking DNS fields such as `enhanced-mode`, `fake-ip-filter-mode`, `respect-rules`, `proxy-server-nameserver`, `nameserver-policy`, `fallback`, and `fallback-filter`.
- Checking rule syntax and rule-provider behavior.

SafeOps translation:

- Unknown OpenClash/Mihomo core version means candidate-only mode.
- Version-sensitive DNS fields must not be written without validation.
- Preserve `proxies`, `proxy-groups`, and `proxy-providers` unless explicitly instructed otherwise.

Do not:

- Add new schema fields solely because a community template uses them.
- Assume a field is supported on old Meta/Mihomo builds.

## Agent Skills documentation

Sources:

- `https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview`
- `https://github.com/anthropics/skills`
- `https://agentskills.io/specification`

Authority: high for Skill packaging, frontmatter conventions, and progressive disclosure.

Use for:

- Keeping `SKILL.md` metadata valid.
- Splitting long content into `references/` and `docs/kb/`.
- Keeping runtime instructions concise.

SafeOps translation:

- `SKILL.md` must start with valid YAML frontmatter.
- `name` and `description` must be present.
- Long operational content belongs in references and KB files.
- Treat `description` as operational trigger text, not marketing copy.

Do not:

- Hide risky behavior in long descriptions.
- Store secrets, router IPs, or subscription URLs in Skill metadata.

## Aethersailor Custom_OpenClash_Rules

Source: `https://github.com/Aethersailor/Custom_OpenClash_Rules/wiki/OpenClash-设置方案`

Authority: medium community baseline for Fake-IP-oriented OpenClash configuration.

Use for:

- Aethersailor-style Fake-IP candidate generation.
- Rule ordering inspiration.
- Overwrite/template design ideas.

SafeOps translation:

- Use only as a profile reference.
- Generate one local candidate YAML for one target config.
- Do not apply network, IPv6, DNS redirection, firewall, or ad-block assumptions automatically.
- Do not inject remote dependencies unless they pass health checks and user approval.

## FFAni OpenClash recommended config guide

Source: `https://ffani.com/post/openwrt-openclash-recommended-config-guide/`

Authority: medium community compatibility guide for Redir-Host + SmartDNS style setups.

Use for:

- Optional Redir-Host + SmartDNS candidate profile.
- Manual DNS leak and compatibility checklists.
- Cases where Fake-IP breaks local services or specific apps.

SafeOps translation:

- SmartDNS, DHCP, WAN/LAN IPv6, and dnsmasq forwarding are manual checklist items by default.
- Do not install or configure SmartDNS automatically.
- Do not edit OpenWrt DHCP/DNS settings without explicit user approval.

## Refresh rule

When upstream documentation changes:

1. Read upstream source manually.
2. Summarize only behavior relevant to SafeOps.
3. Classify authority level.
4. Translate into read-only checks, candidate-only changes, or manual checklists.
5. Update `docs/kb/source-map.md` and this file together.
6. Add a changelog entry.
7. Keep SafeOps boundaries stronger than upstream examples.
