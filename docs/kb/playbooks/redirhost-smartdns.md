# Playbook: Redir-Host + SmartDNS Compatibility

Use FFAni-style Redir-Host + SmartDNS profile only when compatibility matters or SmartDNS already exists.

## Preconditions

- SmartDNS installed and intentionally used.
- Its CN/GW ports are known and listening.
- User understands IPv6/DNS changes can affect all clients.

## Safe process

1. Audit DNS ports.
2. Verify SmartDNS status.
3. Verify OpenClash DNS mode.
4. Generate LuCI guidance for SmartDNS/OpenClash integration.
5. Avoid automatic OpenWrt IPv6/DHCP edits.

## Verification

- `nslookup` domestic and foreign domains.
- client browsing.
- OpenClash logs.
- optional DNS leak tests by user in browser.
