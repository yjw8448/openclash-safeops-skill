# Multi-Subscription Decision Tree

Use this entry whenever the user says:

- "I have two subscriptions."
- "There are two configs."
- "WorkBuddy merged them."
- "One subscription should not affect the other."
- "OpenClash subscription and config mapping is wrong."

## First decision

Do not repair subscription fetching yet. First determine whether the profile boundary is intact.

```text
Can we prove Subscription A -> Config A and Subscription B -> Config B?
├─ Yes -> only repair the selected profile.
├─ No  -> stop and audit backups/config files.
└─ It was merged -> backup bad state, then restore/split.
```

## Required command sequence

```sh
sh scripts/openclash_multisub_audit.sh
python3 scripts/openclash_config_fingerprint.py /etc/openclash/config/*.yaml
```

If scripts are not on the router, use equivalent read-only commands.

## If more than one subscription exists

Never run a one-click profile apply that writes a single shared YAML. Instead:

1. Ask which subscription/profile is being repaired.
2. Back up both profile files.
3. Validate only the selected file.
4. Update only that subscription's generated output.
5. Verify the other profile remains unchanged by fingerprint.

## If WorkBuddy already merged the configs

1. Stop all writes.
2. Backup the bad merged state.
3. Search for backup directories.
4. Compare YAML fingerprints and file mtimes.
5. Restore `/etc/config/openclash` and `/etc/openclash/` from the last pre-merge backup.
6. Do not touch OpenWrt network/dhcp/firewall.

## Human confirmation required

Ask the user before:

- deleting the merged YAML,
- replacing the active profile,
- selecting which profile is active,
- merging profiles intentionally,
- changing profile names.
