# Aethersailor Current-Safe Reference

Use Aethersailor-style rules as a design guide only. Generate a local candidate for exactly one YAML file. Preserve the target file's existing `proxies`, `proxy-groups`, and `proxy-providers` unless the user explicitly asks otherwise.

Safe defaults:
- Fake-IP candidate mode.
- No OpenWrt network/dhcp/firewall edits.
- No remote script execution.
- No multi-subscription merge.
