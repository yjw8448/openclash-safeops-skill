# Subscription Update Decision Tree

## Step 1: Confirm router time and TLS tools

```sh
date
opkg list-installed | grep -E 'ca-bundle|ca-certificates|curl|wget-ssl|openssl' || true
```

Wrong time or missing CA tools can break HTTPS subscriptions.

## Step 2: Confirm DNS for the subscription host

Never print the full subscription URL. Extract and mask the host.

```sh
nslookup example-subscription-host 127.0.0.1 || true
```

If DNS fails, use the DNS playbook first.

## Step 3: Fetch safely

Use `curl -I` or fetch the first bytes only; do not print tokens.

```sh
curl -L --connect-timeout 15 --max-time 30 -I 'SUB_URL' 2>&1 | sed -E 's#(token=)[^& ]+#\1<REDACTED>#g'
```

Look for:

- HTTP 200 with YAML/base64 content.
- 301/302 redirects that curl can follow.
- 401/403/404/410/429.
- HTML login page or Cloudflare page.
- Expired subscription text.

## Step 4: Identify content type

- Clash YAML usually contains `proxies:`, `proxy-groups:`, and `rules:`.
- Base64/V2Ray style may need conversion.
- Surge style may need conversion.
- HTML/error pages are not configs.

## Step 5: Validate converted/generated YAML

Before switching active config:

```sh
python3 scripts/openclash_lint_config.py config.yaml
```

If python is unavailable, use OpenClash logs and basic grep checks.

## Step 6: Common root causes

- Router itself has no DNS/internet.
- System time wrong, TLS fails.
- CA certificates missing.
- Subscription expired or provider blocked router fetch.
- URL requires browser login/cookie.
- Conversion endpoint unavailable.
- Converted YAML has group/rule mismatch.
- Subscription returns nodes only but no complete rules.
