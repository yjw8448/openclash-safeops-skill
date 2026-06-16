# Checklist: Before Writing OpenClash Subscription or Config

Run this before any write operation that touches OpenClash subscriptions, generated YAML, overwrite files, or rule providers.

- [ ] Did we count how many subscriptions exist?
- [ ] Did we identify how many YAML config files exist?
- [ ] Did we know which profile is active?
- [ ] Did we fingerprint current YAML files?
- [ ] Did we backup `/etc/config/openclash` and `/etc/openclash/`?
- [ ] If there are multiple subscriptions, did we avoid merging them?
- [ ] If only one profile should be repaired, did the user identify that profile?
- [ ] Did we confirm that network/dhcp/firewall are not being touched?
- [ ] Did we prepare rollback to the previous OpenClash-only state?
- [ ] Did we avoid printing full subscription URLs?

If any answer is no, stop and ask the user.
