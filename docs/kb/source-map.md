# Source Map

This document maps upstream sources to SafeOps runtime guidance. External sources are reference material only. They must be translated into SafeOps-compatible read-only checks, candidate generation, or manual checklists before use.

## Official OpenClash Wiki

URL: `https://github.com/vernesong/OpenClash/wiki`

Authority level: highest for OpenClash plugin behavior, LuCI concepts, and OpenClash-specific settings.

Operational takeaways:

- OpenClash is an OpenWrt Clash client with rule-based traffic policy routing.
- Use official Wiki areas to route symptoms:
  - Subscription problems -> subscription settings.
  - DNS failures -> DNS settings.
  - Rule failures -> rule/access-control.
  - YAML/config failures -> config file.
  - Dashboard/API failures -> external controller.

Safety translation:

- Treat official settings as UI-level guidance, not permission to rewrite OpenWrt system network files.
- Prefer LuCI/OpenClash UCI options over editing `/etc/config/network`, `/etc/config/dhcp`, or `/etc/config/firewall`.
- If a fix requires system network changes, stop and ask for explicit user approval after risk warning.

## OpenClash Config File Wiki

URL: `https://raw.githubusercontent.com/wiki/vernesong/OpenClash/配置文件.md`

Operational takeaways:

- Config files are YAML/YML.
- Major sections are basic settings, proxies/server information, proxy groups/server-group information, and rules.
- Strategy group and rules sections must stay valid; rules target strategy groups, so group names must match real groups.

Safety translation:

- Always lint YAML before applying.
- Always detect actual group names before adding AI/dev/streaming rules.
- Do not replace a user's config with a template until the current config is backed up.

## OpenClash DNS Wiki

URL: `https://github.com/vernesong/OpenClash/wiki/DNS设置`

Operational takeaways:

- OpenClash uses local DNS hijacking because the Clash core includes a DNS server.
- OpenClash should be the only upstream DNS server for dnsmasq, or other DNS interception/forwarding plugins must be coordinated.
- Fake-IP and Redir-Host modes have different DNS recommendations.
- IPv6 DNS parsing should not be enabled blindly; environments without public IPv6/NAT can break DNS or connectivity.
- Fake-IP advanced settings and fake-ip-filter may be needed for services that break under fake IP responses.

Safety translation:

- Audit port `53`, `7874`, `6053`, and `6553` before changing DNS.
- Treat SmartDNS, MosDNS, AdGuardHome, HomeProxy, and PassWall DNS interception as possible conflicts.
- DNS repair should usually stop OpenClash, restart dnsmasq, verify router DNS, then re-enable OpenClash after config passes.
- Do not auto-edit DHCP or system DNS settings unless explicitly approved.

## OpenClash Subscription Wiki

URL: `https://raw.githubusercontent.com/wiki/vernesong/OpenClash/订阅设置.md`

Operational takeaways:

- OpenClash accepts Clash-type subscriptions and can use API conversion for Surge/V2Ray-type subscriptions.
- Third-party rule subscriptions only take effect when the relevant third-party rules feature is enabled.
- GEOIP database subscriptions are used for fallback IP classification after earlier rules fail.

Safety translation:

- First identify whether the subscription is Clash YAML, base64/V2Ray, Surge, converted YAML, or an error HTML page.
- Check time, DNS, CA certificates, curl/wget, and conversion endpoint before modifying OpenClash.
- Never print raw subscription URLs.

## OpenClash Rule / Access-Control Wiki

URL: `https://raw.githubusercontent.com/wiki/vernesong/OpenClash/规则设置（访问控制）.md`

Operational takeaways:

- Custom rules can be added alongside subscription-managed config and are not affected by subscription updates.
- Rule order matters; earlier rules take priority.
- Rules can match `DOMAIN-SUFFIX`, `DOMAIN-KEYWORD`, `DOMAIN`, `IP-CIDR`, `SRC-IP-CIDR`, `DST-PORT`, and `SRC-PORT`.
- Third-party rules require mapping each rule category to an actual strategy group.

Safety translation:

- Do not assume `Proxy`, `AI`, or `Auto` group names.
- Never add `FINAL`/`MATCH` above specific rules.
- Put LAN/private/router direct rules before proxy rules.

## OpenWrt Official Documentation

URLs:

- `https://openwrt.org/docs/start`
- `https://openwrt.org/docs/guide-user/base-system/uci`
- `https://openwrt.org/docs/guide-user/troubleshooting/failsafe_and_factory_reset`
- `https://openwrt.org/docs/guide-user/troubleshooting/backup_restore`

Authority level: highest for OpenWrt system behavior, recovery concepts, UCI semantics, service management, and failsafe/reset boundaries.

Operational takeaways:

- OpenWrt system recovery is a separate layer from OpenClash repair.
- Failsafe, factory reset, and debricking are physical/local recovery procedures, not ordinary remote SSH repair steps.
- UCI writes to network, DHCP, and firewall can lock users out.

Safety translation:

- Normal SafeOps repair must not edit network/dhcp/firewall.
- If SSH is unavailable, SafeOps cannot safely repair remotely.
- When SSH is unavailable, direct the user to LuCI, failsafe, serial, recovery image, or physical reset workflows.

## Mihomo / MetaCubeX Documentation

URLs:

- `https://wiki.metacubex.one/en/config/`
- `https://wiki.metacubex.one/en/config/dns/`
- `https://wiki.metacubex.one/en/config/rules/`

Authority level: highest for Mihomo core YAML schema behavior.

Operational takeaways:

- DNS fields such as `enhanced-mode`, `fake-ip-filter-mode`, `respect-rules`, `proxy-server-nameserver`, `nameserver-policy`, `fallback`, and `fallback-filter` are core-version-sensitive.
- `respect-rules` requires `proxy-server-nameserver` and should not be combined blindly with `prefer-h3`.
- `fake-ip-filter-mode: rule` changes fake-ip filtering semantics and must be validated against current core support.

Safety translation:

- Do not apply experimental DNS fields without version awareness.
- If core version is unknown, generate a candidate only and warn that runtime compatibility must be verified.
- Keep proxies, proxy-groups, and proxy-providers intact unless the user explicitly asks to modify them.

## Anthropic / Agent Skills Documentation

URLs:

- `https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview`
- `https://github.com/anthropics/skills`
- `https://agentskills.io/specification`

Authority level: high for Skill package structure and `SKILL.md` metadata conventions.

Operational takeaways:

- `SKILL.md` must start with valid YAML frontmatter.
- At minimum, `name` and `description` are required.
- Long reference material should be moved out of `SKILL.md` and loaded progressively from `references/`, `docs/`, or scripts only when needed.

Safety translation:

- Keep `SKILL.md` runtime-critical and concise.
- Use references for long explanations.
- Treat skill metadata as security-sensitive operational text.

## Aethersailor Custom_OpenClash_Rules Wiki

URL: `https://github.com/Aethersailor/Custom_OpenClash_Rules/wiki/OpenClash-设置方案`

Authority level: useful community baseline for Fake-IP and template/overwrite design; not official OpenClash behavior.

Operational takeaways:

- Uses Fake-IP mode.
- Recommends template + overwrite instead of hand-written incomplete YAML.
- Emphasizes reducing DNS plugin nesting and using OpenClash itself where possible.
- Main-router scenario is the assumed baseline; side-router setups need extra caution.

Safety translation:

- Use as a profile, not a universal rule.
- Do not apply its network, DNS, or IPv6 assumptions blindly.
- Good for one-config candidate generation when the user wants Fake-IP and maintainable rules.

## FFAni OpenClash Recommended Config Guide

URL: `https://ffani.com/post/openwrt-openclash-recommended-config-guide/`

Authority level: community compatibility guide, especially for Redir-Host, SmartDNS, IPv6, and DNS leak checks.

Operational takeaways:

- Recommends Redir-Host compatibility mode.
- Focuses on IPv6 optimization, SmartDNS integration, DNS leak prevention, and optional ad blocking.
- Uses Dnsmasq forwarding and SmartDNS CN/GW grouping in the guide.

Safety translation:

- Treat IPv6, SmartDNS, and DHCP/DNS changes as medium/high risk.
- Do not change OpenWrt IPv6 WAN/LAN/DHCP settings from this skill unless user explicitly approves.
- Use this as an optional profile when Fake-IP causes compatibility problems or SmartDNS already exists.

## Local Policy Additions

### v5

- `docs/MULTI_SUBSCRIPTION_ISOLATION.md` — Local SafeOps policy for preserving user-defined subscription/config boundaries.
- `docs/kb/75-multi-subscription-decision-tree.md` — Decision tree for multi-subscription audits and accidental merge recovery.

### v7.4

- `docs/kb/81-report-generation-and-sync.md` — Report freshness, latest-report plus timestamped snapshot policy, and local/router report sync handling.
- `docs/kb/82-active-config-update-url-binding.md` — Active `config_path`, `config_update_url`, and `auto_update` consistency checks for cases where selecting one YAML automatically switches back to another provider.
- `docs/kb/83-local-ssh-helper-hygiene.md` — Local WorkBuddy SSH helper handling policy: audit for embedded secrets, do not delete reusable helper scripts unless the user explicitly asks.

### v7.7

- `references/upstream-sources.md` — Authority map and safe translation rules for official and community sources.
- `references/skill-authoring.md` — Skill packaging and progressive disclosure guidance.
- `docs/kb/31-openwrt-operational-safety.md` — OpenWrt-layer safety and recovery boundaries.
- `docs/kb/32-mihomo-schema-compatibility.md` — Mihomo/OpenClash core schema compatibility checks.
- `docs/kb/84-upstream-reference-refresh-policy.md` — Safe refresh policy for bundled upstream references.
