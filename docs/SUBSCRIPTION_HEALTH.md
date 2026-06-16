# Subscription Health Check

Run:

```sh
SUB_URL='https://example.com/your-sub' sh openclash_subscription_health.sh
```

The script checks:

- System time.
- TLS/CA packages.
- Whether curl/wget can fetch the subscription.
- Whether the response is YAML, Base64, or an HTML/error/login page.
- Whether structural keywords like `proxies`, `proxy-groups`, and `rules` appear.

Do not paste full subscription URLs into chat. Redact them.
