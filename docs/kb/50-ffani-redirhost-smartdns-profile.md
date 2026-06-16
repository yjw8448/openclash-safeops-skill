# FFAni Redir-Host + SmartDNS Profile Summary

## When to use

Use as a compatibility profile when Fake-IP breaks apps, LAN services, NTP/DDNS, or the user already relies on SmartDNS/IPv6.

## Profile principles

- Redir-Host compatibility mode.
- Dnsmasq forwarding approach.
- SmartDNS CN/GW grouping when SmartDNS is installed and intentionally used.
- IPv6 optimization and DNS leak prevention are major goals.
- Optional ad-blocking is not part of emergency repair.

## SafeOps translation

Before applying:

1. Verify SmartDNS exists and its ports.
2. Verify dnsmasq and OpenClash DNS listeners.
3. Verify WAN IPv6-PD before touching IPv6 settings.
4. Treat all IPv6/DHCP/DNS announcement changes as high risk.
5. Use LuCI notes for user confirmation instead of making network/dhcp edits automatically.

## DNS points to audit

- Is dnsmasq forwarding to OpenClash, SmartDNS, or both?
- Is OpenClash local DNS hijack enabled?
- Is another plugin hijacking port 53 through firewall rules?
- Are fallback/default-nameserver settings causing leaks or inconsistent results?
- Are SmartDNS first/second DNS ports such as 6053/6553 actually listening?

## What not to copy blindly

- Do not change WAN/LAN IPv6, DHCPv6, RA, or DNS announcement settings automatically.
- Do not set SmartDNS as upstream unless SmartDNS is installed, running, and intentionally configured.
- Do not introduce ad-blocking while repairing subscription or connectivity.
