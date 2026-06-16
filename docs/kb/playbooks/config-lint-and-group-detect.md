# Playbook: Config Lint and Group Detect

## Purpose

Prevent OpenClash startup failure caused by invalid YAML, missing sections, bad rule targets, or non-existent strategy groups.

## Commands

```sh
python3 scripts/openclash_lint_config.py /etc/openclash/config/*.yaml
python3 scripts/openclash_group_detect.py /etc/openclash/config/*.yaml --env
```

If Python is unavailable:

```sh
grep -nE '^(proxies|proxy-groups|rules|rule-providers|proxy-providers):' /etc/openclash/config/*.yaml || true
grep -nE 'name:|MATCH|GEOIP|DOMAIN' /etc/openclash/config/*.yaml | head -200 || true
logread | grep -iE 'yaml|parse|openclash|mihomo|clash' | tail -120 || true
```

## Required checks

- YAML parses.
- proxies or proxy-providers exist.
- proxy-groups exist.
- rules exist or third-party rules are intentionally used.
- rules target real groups or built-in DIRECT/REJECT.
- final rule is last.
- external-controller and DNS ports do not conflict.
