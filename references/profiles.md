# Configuration profiles

## `fakeip-aethersailor`

Use when the user wants modern rule routing and the network tolerates Fake-IP.

Recommended elements:

- Meta/Mihomo core.
- Rule mode.
- Fake-IP after compatibility check.
- Mainland bypass where appropriate.
- Subscription conversion with a known template.
- Overwrite module for DNS/rules/custom groups.
- Rule-providers for AI, developer sites, streaming, direct, and reject.
- Avoid unnecessary DNS plugin nesting.

## `redirhost-smartdns`

Use when Fake-IP causes compatibility problems or SmartDNS already exists.

Recommended elements:

- Redir-Host compatibility mode.
- dnsmasq forwarding coordinated with OpenClash.
- SmartDNS CN/GW grouping only when SmartDNS is installed and the user understands it.
- IPv6 only after confirming WAN IPv6-PD and LAN RA/DHCPv6 behavior.
- DNS leak tests after configuration.

## `minimal-safe`

Use when the router was recently broken or the user wants the least invasive setup.

Recommended elements:

- Do not touch OpenWrt network/dhcp/firewall.
- Generate rule files and overwrite snippets only.
- Keep OpenClash stopped until config validates.
- Ask the user to apply risky LuCI settings manually.
