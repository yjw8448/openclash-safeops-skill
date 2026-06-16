# Playbook: Diagnose First

## Goal

Collect evidence without changing router state.

## Command block

```sh
echo "===== System ====="
cat /etc/openwrt_release 2>/dev/null || true
uname -a
date
uptime

echo "===== Route / IP ====="
ip route
ip addr show | grep -E '^[0-9]+:|inet '

echo "===== Services ====="
/etc/init.d/openclash status 2>/dev/null || true
/etc/init.d/dnsmasq status 2>/dev/null || true
/etc/init.d/uhttpd status 2>/dev/null || true

echo "===== Ports ====="
netstat -lntup 2>/dev/null | grep -E ':53|:80|:443|:22|:7890|:7891|:7892|:7874|:9090|:6053|:6553' || true

echo "===== DNS / Network ====="
ping -c 3 223.5.5.5 || true
ping -c 3 8.8.8.8 || true
nslookup baidu.com 127.0.0.1 || true
nslookup github.com 127.0.0.1 || true
curl -I --connect-timeout 10 https://openwrt.org || true
curl -I --connect-timeout 10 https://github.com || true

echo "===== OpenClash ====="
ls -lah /etc/openclash 2>/dev/null || true
ls -lah /etc/openclash/config 2>/dev/null || true
uci show openclash 2>/dev/null | sed -E 's#(http|https)://[^ ]+#<URL_REDACTED>#g; s#secret=.*#secret=<REDACTED>#g; s#password=.*#password=<REDACTED>#g' || true
logread | grep -i openclash | tail -n 120 || true
```

## Output required

- Can router ping IP addresses?
- Can router resolve DNS?
- Is OpenClash running/stopped/failing?
- Are DNS-related ports occupied?
- Is subscription config present?
- Which playbook should run next?
