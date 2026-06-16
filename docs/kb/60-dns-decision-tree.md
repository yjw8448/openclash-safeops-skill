# DNS Decision Tree

## Step 1: Is router IP connectivity working?

Run:

```sh
ping -c 3 223.5.5.5 || true
ping -c 3 8.8.8.8 || true
ip route
```

If IP ping fails, this is not just DNS. Stop OpenClash and verify WAN route. Do not restart network unless explicitly confirmed.

## Step 2: Who listens on DNS-related ports?

Run:

```sh
netstat -lntup 2>/dev/null | grep -E ':53|:7874|:6053|:6553|:5335|:5353' || true
/etc/init.d/dnsmasq status 2>/dev/null || true
/etc/init.d/smartdns status 2>/dev/null || true
/etc/init.d/AdGuardHome status 2>/dev/null || true
/etc/init.d/mosdns status 2>/dev/null || true
/etc/init.d/homeproxy status 2>/dev/null || true
```

Expected simple pattern:

- dnsmasq owns LAN port 53.
- OpenClash listens on its local DNS port, commonly 7874 or configured equivalent.
- Other DNS plugins are either disabled or explicitly chained.

## Step 3: Test local resolver and direct resolver

```sh
nslookup baidu.com 127.0.0.1 || true
nslookup github.com 127.0.0.1 || true
nslookup baidu.com 223.5.5.5 || true
```

If `127.0.0.1` fails but public DNS works, repair dnsmasq/OpenClash local DNS chain.

## Step 4: Is OpenClash stopped but DNS still broken?

If yes, dnsmasq upstream may still point to OpenClash/SmartDNS dead port. Restart dnsmasq and inspect DHCP UCI output. Do not edit dhcp automatically unless user approves.

## Step 5: Choose a repair branch

### Branch A: No SmartDNS intended

- Stop OpenClash.
- Restart dnsmasq.
- Verify router DNS.
- Fix OpenClash DNS settings only.
- Start OpenClash after YAML passes.

### Branch B: SmartDNS intended

- Verify SmartDNS listening ports.
- Verify SmartDNS groups/upstreams.
- Configure OpenClash to use SmartDNS only through documented local ports.
- Do not change OpenWrt DHCP/DNS announcement automatically.

### Branch C: Multiple DNS plugins installed accidentally

- Do not uninstall automatically.
- Disable extra DNS hijack features only after backup and user confirmation.
- Prefer leaving one DNS authority path.
