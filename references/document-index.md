# Document index

Read only the documents relevant to the user's current symptom.

| Symptom / task | Read this first |
|---|---|
| General symptom routing | `docs/kb/10-symptom-router.md` |
| Safety boundaries | `docs/kb/20-safety-boundaries.md` |
| Official Wiki concepts | `docs/kb/30-openclash-official-wiki.md`, `docs/OFFICIAL_WIKI_REFERENCE.md` |
| Fake-IP / Aethersailor profile | `docs/kb/40-aethersailor-fakeip-profile.md` |
| Redir-Host + SmartDNS profile | `docs/kb/50-ffani-redirhost-smartdns-profile.md` |
| DNS abnormal / DNS conflict | `docs/kb/60-dns-decision-tree.md`, `docs/DNS_CONFLICT_AUDIT.md` |
| Subscription update failure | `docs/kb/70-subscription-decision-tree.md`, `docs/SUBSCRIPTION_HEALTH.md` |
| Multiple subscriptions | `docs/kb/75-multi-subscription-decision-tree.md`, `docs/MULTI_SUBSCRIPTION_ISOLATION.md` |
| No subscription information / unbound YAML | `docs/kb/76-unbound-config-decision-tree.md`, `docs/UNBOUND_CONFIG_RECOVERY.md` |
| Rules not effective | `docs/kb/80-rule-design-and-group-mapping.md`, `docs/RULE_DESIGN.md` |
| LuCI navigation | `docs/kb/90-luci-navigation-map.md`, `docs/LUCI_CLICK_GUIDE.md` |
| Emergency restore | `docs/kb/playbooks/emergency-restore.md`, `docs/EMERGENCY_MODE.md` |
| Restore two subscriptions | `docs/kb/playbooks/restore-two-subscriptions.md` |
| `config-a.yaml` shows no subscription info | `docs/kb/playbooks/no-subscription-info-unbound-config.md` |
| Watchdog usage | `docs/WATCHDOG_USAGE.md`, `docs/V3_ANTI_LOCKOUT.md` |
| Config linting | `docs/CONFIG_LINT_RULES.md` |
| Version compatibility | `docs/VERSION_COMPATIBILITY.md` |
| One-click profiles | `docs/ONECLICK_PROFILES.md` |
| SSH repair runbook | `docs/SSH_REPAIR_RUNBOOK.md` |
| Recovery and rollback | `docs/RECOVERY.md` |
| Knowledge-base source map | `docs/kb/source-map.md` |
| Single-config template application | `docs/kb/77-single-config-template-apply.md`, `references/template-apply.md`, `references/templates-reference.md`, `templates/` |
| FFAni template for one config | `references/template-apply.md`, `docs/kb/50-ffani-redirhost-smartdns-profile.md`, `templates/ffani-redirhost-smartdns-overlay.yaml` |
| One-click templates / overwrite snippets | `references/templates-reference.md`, `templates/` |
| Aethersailor Current-Safe single-config generation | `references/aethersailor-current-safe.md`, `references/aethersailor-source-snapshot.md`, `docs/kb/79-aethersailor-current-safe-config-generation.md`, `templates/aethersailor-current-safe-overlay.yaml` |
| Aethersailor Legacy-Safe single-config generation | `references/aethersailor-legacy-safe.md`, `docs/kb/40-aethersailor-fakeip-profile.md`, `templates/aethersailor-legacy-safe-overlay.yaml` |

## v7.4 reporting and binding consistency

- Stale or missing `openclash_fix_report.md` -> `docs/kb/81-report-generation-and-sync.md`, `references/reporting.md`.
- Active config switches back after selecting another YAML -> `docs/kb/82-active-config-update-url-binding.md`.
- Local SSH helper scripts created by WorkBuddy -> `docs/kb/83-local-ssh-helper-hygiene.md`.
