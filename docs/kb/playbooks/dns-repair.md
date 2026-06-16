# Playbook: DNS Repair

## Diagnose first

Read `60-dns-decision-tree.md`.

## Safe repair order

1. Stop OpenClash.
2. Restart dnsmasq.
3. Verify router DNS.
4. Audit other DNS plugins.
5. Fix only OpenClash DNS settings or documented DNS chain.
6. Validate config.
7. Start OpenClash.
8. Verify DNS and browsing.

## Common findings

- dnsmasq forwards to a dead OpenClash port.
- SmartDNS listens but OpenClash points to the wrong port.
- AdGuard/MosDNS/HomeProxy/PassWall DNS hijack conflicts with OpenClash local DNS hijack.
- IPv6 DNS is enabled without valid IPv6 environment.
- Fake-IP missing filter exception for a broken service.

## Do not

- Change DHCP DNS announcement automatically.
- Rewrite `/etc/config/dhcp` automatically.
- Enable/disable IPv6 globally without explicit confirmation.
