# Playbook: Emergency Restore

Use when SSH works but OpenClash/DNS may have broken internet or LuCI.

## Allowed actions

- Stop OpenClash.
- Kill orphaned clash/mihomo processes.
- Restart dnsmasq.
- Restart uhttpd.
- Verify DNS and internet.

## Forbidden actions

- `/etc/init.d/network restart`
- edit network/dhcp/firewall
- reboot

## Commands

```sh
/etc/init.d/openclash stop 2>/dev/null || true
killall clash 2>/dev/null || true
killall mihomo 2>/dev/null || true
/etc/init.d/dnsmasq restart 2>/dev/null || true
/etc/init.d/uhttpd restart 2>/dev/null || true
sleep 5
nslookup baidu.com 127.0.0.1 || true
curl -I --connect-timeout 10 https://openwrt.org || true
```

After emergency restore, leave OpenClash stopped until DNS and YAML checks pass.
