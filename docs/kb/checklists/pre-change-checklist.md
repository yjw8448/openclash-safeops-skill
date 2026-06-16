# Pre-change Checklist

- SSH is stable.
- LuCI/uhttpd status checked.
- Read-only diagnosis collected.
- Backup created and path printed.
- Subscription URLs and secrets masked.
- Risk level stated.
- Watchdog started for medium-risk changes.
- No changes to network/dhcp/firewall unless explicitly confirmed.
- YAML linted if config will be changed.
- Strategy groups detected if rules will be changed.
