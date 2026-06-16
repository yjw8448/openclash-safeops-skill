# Template Apply Workflow

1. Set exactly one `TARGET_FILE`.
2. Run multi-subscription and binding audits.
3. Run `openclash_single_config_template_guard.sh`.
4. Generate candidate with `openclash_template_apply.py`.
5. Lint candidate.
6. Ask user before `--apply`.
