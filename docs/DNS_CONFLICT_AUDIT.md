# DNS Conflict Audit

DNS is the most common OpenClash breakage area.

Run:

```sh
sh openclash_dns_audit.sh
```

Look for:

- Multiple services listening on port 53.
- OpenClash local DNS and dnsmasq upstream disagreement.
- SmartDNS/AdGuardHome/MosDNS/HomeProxy all enabled at once.
- Fake-IP plus an extra cache/filter layer in front.
- DNS works via `223.5.5.5` but fails via `127.0.0.1`.

Safe first repair:

```sh
sh openclash_emergency_restore.sh --apply
```

Then keep OpenClash stopped until:

```sh
sh openclash_dns_audit.sh
python3 openclash_lint_config.py /etc/openclash/config.yaml
```

both look sane.
