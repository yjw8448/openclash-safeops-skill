# Local SSH Helper Hygiene

Use this when WorkBuddy creates local SSH helper scripts such as `ssh_connect.py`.

## Policy

Do not delete local SSH helper scripts automatically. They can be useful for later maintenance and repeated diagnosis.

## Safe handling

1. Report the path of the helper script.
2. Check whether it contains raw password, token, or subscription URL.
3. Recommend replacing embedded credentials with environment variables or a local credential manager.
4. Delete only if the user explicitly requests deletion.

## Redaction

Never copy helper script contents into the response without redaction.
