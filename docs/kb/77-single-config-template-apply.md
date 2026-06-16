# Single-config template application decision tree

Use this when the user wants to modify exactly one current OpenClash config according to a template.

## Decision tree

1. Is the target config explicit?
   - Yes: continue.
   - No: ask for the target file name or identify the active config read-only.

2. Are there multiple subscriptions or multiple YAML files?
   - Yes: run multi-subscription and binding audits before any write.
   - No: continue.

3. Does the target show `无订阅信息`?
   - Yes: switch to unbound-config recovery before applying a template.
   - No: continue.

4. Does the template require external services?
   - FFAni Redir-Host + SmartDNS: verify SmartDNS and ports 6053/6553.
   - AI/dev rules: verify strategy-group names.
   - Minimal-safe: verify basic YAML structure.

5. Can a candidate be created and linted?
   - Yes: show diff and wait for approval.
   - No: stop and report the exact blocker.

6. Did the user approve the write?
   - Yes: overwrite only the target YAML from the candidate.
   - No: keep candidate only.

## Never do

- Never apply a template to all configs.
- Never merge two subscriptions.
- Never edit proxies or proxy-groups unless the user explicitly requests a group rename plan.
- Never write to OpenWrt network/dhcp/firewall.
