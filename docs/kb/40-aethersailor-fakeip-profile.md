# Aethersailor Fake-IP Profile Summary

## When to use

Use this profile when the user wants a modern OpenClash setup, maintainable template/overwrite workflow, and is comfortable with Fake-IP behavior.

## Profile principles

- Use Fake-IP mode.
- Prefer subscription conversion + template + overwrite rather than manually writing incomplete YAML.
- Use OpenClash itself for DNS/rule routing as much as possible; avoid unnecessary DNS plugin nesting.
- Keep rule data and GEO databases updated on staggered schedules.
- Prefer main-router assumptions. Side-router setups need caution.

## SafeOps translation

Before applying:

1. Diagnose current topology.
2. Confirm OpenClash is the intended DNS/routing component.
3. Backup `/etc/config/openclash` and `/etc/openclash`.
4. Lint the current generated config.
5. Detect group names.
6. Dry-run generated overwrite/rules.
7. Start watchdog before applying.

## What not to copy blindly

- Do not change OpenWrt LAN/DHCP/firewall as part of this profile.
- Do not apply IPv6 or side-router assumptions without explicit confirmation.
- Do not assume all nodes support UDP/IPv6.
- Do not remove existing fake-ip-filter entries unless you know why.

## Typical repair relevance

- Good for users whose config has too much manual YAML damage.
- Good for stable AI/dev/streaming rule-provider design.
- Good for replacing fragile hand-edited rules with overwrite snippets.
