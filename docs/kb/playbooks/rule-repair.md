# Playbook: Rule Repair

## When to use

Rules not taking effect, AI/GitHub not proxied, domestic traffic proxied unexpectedly, or OpenClash logs rule errors.

## Safe process

1. Detect groups.
2. Review rules order.
3. Confirm `MATCH` is final.
4. Replace placeholder group names with real groups.
5. Add custom rules via overwrite/access-control path instead of editing generated YAML when possible.
6. Verify with DNS/API/logs.

## Do not

- Add `MATCH` before specific rules.
- Assume group names.
- Remove subscription rules without backup.
