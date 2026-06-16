# Templates reference

Use the `templates/` directory for dry-run profile generation, overwrite snippets, group mapping, and rule examples. Do not apply templates directly to a router until the current subscription/config mapping is known, backups exist, and the multi-subscription guard passes.

| Template | Purpose | Use when | Notes |
|---|---|---|---|
| `templates/oneclick-profile.env.example` | Environment variables for one-click profile generation. | Preparing a controlled dry-run or `openclash_oneclick_config.sh`. | Copy to a private `.env` file and never commit real subscription URLs. |
| `templates/group-map.env.example` | Example mapping from real subscription strategy groups to roles such as AI/Proxy/Auto/Final. | Rules need to match the user's actual `proxy-groups`. | Generate or adjust after `openclash_group_detect.py --env`. |
| `templates/overwrite-safe-basic.yaml` | Minimal safe overwrite snippet. | Recovering from breakage or building a low-risk baseline. | Prefer this for recently broken routers. |
| `templates/overwrite-ai-dev.yaml` | AI/developer-oriented overwrite snippet. | Adding AI/GitHub/developer rules after groups are verified. | Requires valid group names. |
| `templates/redirhost-smartdns-notes.yaml` | Notes/snippet for Redir-Host + SmartDNS style setups. | Fake-IP is unsuitable or SmartDNS is already installed. | Audit DNS conflicts first. |
| `templates/rules-ai-classical.yaml` | Classical rule examples for AI services. | Creating AI routing rules. | Do not use until the AI strategy group is confirmed. |
| `templates/rules-dev-classical.yaml` | Classical rule examples for developer sites. | Creating GitHub/Docker/developer routing rules. | Do not override local/LAN direct rules. |

## Safety checklist before applying templates

1. Run `openclash_multisub_audit.sh`.
2. Run `openclash_subscription_binding_audit.sh` when more than one subscription/config exists.
3. Run `openclash_group_detect.py` for real group names.
4. Back up OpenClash config and `/etc/openclash/`.
5. Start watchdog for medium-risk writes.
6. Verify connectivity before disarming watchdog.
