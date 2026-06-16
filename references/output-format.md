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
