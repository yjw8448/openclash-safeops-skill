# Playbook: Post-Repair Verification

Run after any repair.

```sh
echo "===== Service Status ====="
/etc/init.d/openclash status 2>/dev/null || true
/etc/init.d/dnsmasq status 2>/dev/null || true
/etc/init.d/uhttpd status 2>/dev/null || true

echo "===== DNS ====="
nslookup baidu.com 127.0.0.1 || true
nslookup github.com 127.0.0.1 || true
nslookup openai.com 127.0.0.1 || true

echo "===== Connectivity ====="
ping -c 3 223.5.5.5 || true
curl -I --connect-timeout 10 https://openwrt.org || true
curl -I --connect-timeout 10 https://github.com || true

echo "===== OpenClash Logs ====="
logread | grep -i openclash | tail -n 120 || true
```

Report:

- Router internet: ok/fail.
- DNS: ok/fail.
- OpenClash: running/stopped/fail.
- Subscription: update ok/fail/not tested.
- Clients: user must test phone/PC.
- Backup path and rollback command.
