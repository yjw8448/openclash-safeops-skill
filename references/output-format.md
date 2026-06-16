# Required output format

Every OpenClash SafeOps run should report:

1. Current judgment.
2. Risk level.
3. Router access status: SSH/LuCI/dnsmasq/OpenClash.
4. Subscription count and config file count.
5. Whether multiple subscriptions or unbound configs were detected.
6. Commands run or proposed.
7. Files changed, if any.
8. Backup directory.
9. Watchdog status.
10. Rollback command.
11. Verification result.
12. Whether OpenClash is left running or stopped.
13. Next action requiring user confirmation.

Mask subscription URLs, passwords, dashboard secrets, and tokens.


Template runs should additionally report:

1. Target YAML file.
2. Template profile or overlay file.
3. Candidate YAML path.
4. Modified YAML sections.
5. Protected sections preserved, especially `proxies`, `proxy-groups`, and providers.
6. Diff summary and lint result.
7. Whether user approval is still required before overwrite.
