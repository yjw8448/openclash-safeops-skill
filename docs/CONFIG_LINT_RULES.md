# Config Lint Rules

Run:

```sh
python3 openclash_lint_config.py /etc/openclash/config.yaml
```

The linter checks:

- YAML parse validity.
- Config root is a mapping.
- Proxy/server section exists.
- `proxy-groups` exists.
- `rules` exists.
- Duplicate proxy/proxy-group names.
- Rules target missing groups.
- `RULE-SET` references missing rule-providers.
- Proxy groups reference missing proxies/groups/providers.
- `MATCH` is final.
- DNS section and Fake-IP local filter warnings.

Errors should be fixed before starting OpenClash. Warnings need human review.
