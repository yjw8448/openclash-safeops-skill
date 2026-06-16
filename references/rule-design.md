# Rule design reference

General rule priority:

1. LAN/private/direct rules.
2. Router, NAS, printer, and local domains.
3. User force-direct list.
4. User force-proxy list.
5. AI service rules.
6. Developer rules such as GitHub, Docker, npm, pip.
7. Streaming rules.
8. Domestic direct rules.
9. GEOIP CN direct rules.
10. Final `MATCH` to the default proxy group.

Before generating rules, detect real strategy-group names:

```sh
python3 scripts/openclash_group_detect.py /etc/openclash/config/*.yaml --env
```

Never assume groups are named `Proxy`, `AI`, `DIRECT`, or `REJECT`. Map to existing groups or ask the user.
