# Unbound Config Pre-write Checklist

Before writing any OpenClash config when LuCI shows **无订阅信息**:

- [ ] Backed up current `/etc/config/openclash` and `/etc/openclash/`.
- [ ] Ran `openclash_no_subinfo_audit.sh`.
- [ ] Ran `openclash_subscription_binding_audit.sh`.
- [ ] Counted visible subscription URLs.
- [ ] Checked whether selected YAML basename appears in UCI.
- [ ] Checked YAML fingerprints for accidental identical/merged configs.
- [ ] Identified whether the YAML is bound, local/manual, or suspected merged.
- [ ] If multiple subscriptions exist, confirmed one subscription -> one config mapping.
- [ ] Asked user before restoring, deleting, splitting, or rebuilding.
- [ ] Did not modify network/dhcp/firewall.
- [ ] Did not restart network.
