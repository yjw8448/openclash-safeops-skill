# Baseline reference sources

Use these sources as conceptual references. Do not blindly copy remote settings into a user's router.

## OpenClash official Wiki

- Treat OpenClash as an OpenWrt LuCI client for Clash/Mihomo-style rule proxying.
- Map issues to installation, status, quick setup, subscription settings, configuration file, general settings, DNS settings, rules/access control, external controller, and update pages.
- Treat YAML/YML files as structured configuration with basic settings, proxies, proxy groups, and rules.
- Treat DNS as a common breakage point involving OpenClash local DNS, dnsmasq upstream, and other DNS plugins.

## Aethersailor / Custom_OpenClash_Rules

- Use as a reference for Fake-IP, subscription conversion, overwrite modules, and rule routing.
- Prefer templates and overwrite files over low-quality hand-written YAML.
- Avoid unnecessary DNS plugin nesting.

## FFAni Redir-Host + SmartDNS profile

- Use as an optional compatibility reference when Fake-IP breaks LAN/app behavior or when SmartDNS already exists.
- Treat SmartDNS and IPv6 changes as medium/high risk because they affect every client.

## OpenWrt safety baseline

- Treat `/etc/config/network`, `/etc/config/dhcp`, and `/etc/config/firewall` as router-wide high-risk files.
- Prefer fixing OpenClash over changing OpenWrt network/firewall.
