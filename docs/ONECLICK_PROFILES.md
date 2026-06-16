# One-click profiles

The one-click script is intentionally conservative. It writes templates and notes, not blind UCI mutations. OpenClash UCI option names differ by version and build, so high-confidence checks and LuCI application are safer.

## Profile: fakeip-aethersailor

Best for:
- Main-router OpenWrt.
- Users comfortable with Fake-IP.
- Modern Mihomo/OpenClash setups.
- Rule-provider and subscription-conversion workflows.

Generated assets:
- `safeops-rule-providers.yaml`
- `safeops-rules.yaml`
- `safeops-overwrite-notes.yaml`
- `README-apply-in-luci.md`

Manual LuCI review:
- Core: Mihomo/Meta.
- Mode: Rule.
- DNS: ensure OpenClash/dnsmasq chain has no competing DNS hijacker.
- Subscription conversion: use a trusted template, such as Aethersailor-style template, if compatible.
- Overwrite: import generated snippets only after group names are verified.

## Profile: redirhost-smartdns

Best for:
- Apps/LAN devices broken by Fake-IP.
- Existing SmartDNS setup.
- IPv6-aware setups.

Generated assets:
- SmartDNS/OpenClash integration notes.
- Redir-Host DNS notes.
- DNS leak test checklist.

Manual LuCI review:
- Mode: Redir-Host compatibility.
- DNS: Dnsmasq forwarding; avoid multiple hijackers.
- SmartDNS: use CN/GW groups only if SmartDNS is confirmed healthy.
- IPv6: enable only after OpenWrt WAN IPv6-PD and LAN RA/DHCPv6 are confirmed.

## Profile: minimal-safe

Best for:
- Recently broken router.
- User wants to avoid risk.
- Initial recovery after OpenClash caused disconnection.

Generated assets:
- Rule snippets only.
- No service restart by default.
- No UCI writes except optional OpenClash-owned safeops directory.
