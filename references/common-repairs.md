# Common repair decisions

## OpenClash starts and kills internet

1. Stop OpenClash.
2. Restart dnsmasq.
3. Verify DNS and default route.
4. Inspect OpenClash logs.
5. Validate YAML.
6. Audit DNS/port conflicts.
7. Re-enable only after identifying root cause.

## Subscription update fails

1. Check system time and CA bundle.
2. Check DNS resolution for the subscription host.
3. Fetch subscription with redacted logging.
4. Detect HTML, login page, 403, expired account, or Cloudflare page.
5. Detect YAML/Base64 format.
6. Validate converted config.

## Rules do not work

1. Detect strategy groups.
2. Lint rules and provider references.
3. Check `MATCH` position.
4. Confirm custom rules are inserted before domestic direct/final rules.
5. Test with dashboard/API if available.

## Two subscriptions were merged

1. Stop current writes.
2. Back up the bad merged state.
3. Audit current profiles and backup directories.
4. Restore only `/etc/config/openclash` and `/etc/openclash/` from confirmed pre-merge backup.
5. Do not restore network/dhcp/firewall.
6. Ask which profile should be active before starting OpenClash.

## `config-a.yaml` or another YAML shows no subscription information

1. Back up the current unbound state.
2. Audit subscription binding records.
3. Fingerprint YAML files.
4. Determine whether the file is local, generated, restored, or merged.
5. Do not treat it as a normal subscription-managed config until mapping is proven.
