# Playbook: Fake-IP Baseline

Use Aethersailor-style Fake-IP baseline only after the user confirms this profile.

## Dry-run first

- Explain Fake-IP tradeoffs.
- Audit DNS conflicts.
- Detect group names.
- Generate overwrite snippets.
- Do not modify network/dhcp/firewall.

## Apply requirements

- Backup.
- Watchdog.
- Validate YAML.
- Verify router DNS, client browsing, NTP/DDNS/LAN apps.

## Rollback

- Restore previous OpenClash config.
- Stop OpenClash.
- Restart dnsmasq.
- Leave network untouched.
