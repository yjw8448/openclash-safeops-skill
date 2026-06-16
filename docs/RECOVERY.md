# Recovery

## If SSH still works

Run:

```sh
/etc/init.d/openclash stop 2>/dev/null || true
killall clash 2>/dev/null || true
killall mihomo 2>/dev/null || true
/etc/init.d/dnsmasq restart 2>/dev/null || true
/etc/init.d/uhttpd restart 2>/dev/null || true
```

Then test:

```sh
ip route
nslookup openwrt.org 127.0.0.1
curl -I -L --connect-timeout 5 --max-time 12 https://openwrt.org
```

## If LuCI works but SSH does not

- Confirm SSH service/dropbear is enabled.
- Confirm you are using the router's current LAN IP.
- Disable browser/system proxy and VPN on the client.
- Do not change LAN IP unless you are connected by Ethernet and have a rollback path.

## If SSH and LuCI do not work

- Connect by Ethernet directly to a LAN port.
- Check your computer's gateway IP.
- Try the gateway in browser and SSH.
- Disable client proxy/VPN.
- Use OpenWrt failsafe mode if supported.
- Restore backup from failsafe/serial.

## Do not do these as first aid

```sh
/etc/init.d/network restart
uci commit network
uci commit firewall
firstboot
sysupgrade
reboot
```

These can make recovery harder if LAN/DHCP/firewall is already damaged.
