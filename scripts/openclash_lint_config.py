#!/usr/bin/env python3
"""Deep lint for OpenClash/Mihomo YAML config.

Usage:
  python3 openclash_lint_config.py /etc/openclash/config.yaml
  python3 openclash_lint_config.py /etc/openclash/config.yaml --strict

This script is read-only.
"""
from __future__ import annotations
import argparse, json, re, sys
from pathlib import Path
from collections import Counter

BUILTINS = {"DIRECT", "REJECT", "REJECT-DROP", "PASS", "COMPATIBLE", "GLOBAL"}
PROXY_KEYS = ("proxies", "Proxy")
PROVIDER_KEYS = ("proxy-providers", "proxy-provider")


def load_yaml(path: Path):
    try:
        import yaml  # type: ignore
    except Exception as exc:
        print("ERROR: Python module 'yaml' is missing. Install PyYAML or run this on a machine that has it.")
        print(f"detail: {exc}")
        return None, 2
    try:
        with path.open("r", encoding="utf-8") as f:
            return yaml.safe_load(f), 0
    except Exception as exc:
        print(f"ERROR: YAML parse failed: {type(exc).__name__}: {exc}")
        return None, 2


def split_rule(rule: str):
    # Good enough for OpenClash classical rules; quotes are rare in rule lines.
    return [x.strip() for x in rule.split(",")]


def rule_target(parts):
    if len(parts) < 2:
        return None
    if parts[-1].lower() == "no-resolve" and len(parts) >= 3:
        return parts[-2]
    if len(parts) >= 3:
        return parts[-1]
    return None


def section_order_warnings(text: str):
    # Official Wiki describes the conceptual order: basic settings -> proxy/server info -> proxy groups -> rules.
    keys = []
    for m in re.finditer(r"(?m)^([A-Za-z0-9_-]+)\s*:", text):
        k = m.group(1)
        if k in {"proxies", "Proxy", "proxy-providers", "proxy-provider", "proxy-groups", "rule-providers", "rules"}:
            keys.append((k, m.start()))
    pos = {k: p for k, p in keys}
    warnings = []
    proxy_pos = min([pos[k] for k in ("proxies", "Proxy", "proxy-providers", "proxy-provider") if k in pos], default=None)
    group_pos = pos.get("proxy-groups")
    rules_pos = pos.get("rules")
    if proxy_pos is not None and group_pos is not None and proxy_pos > group_pos:
        warnings.append("Section order: proxy/server section appears after proxy-groups.")
    if group_pos is not None and rules_pos is not None and group_pos > rules_pos:
        warnings.append("Section order: proxy-groups appears after rules.")
    return warnings


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("config")
    ap.add_argument("--strict", action="store_true", help="exit non-zero on warnings as well as errors")
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()

    path = Path(args.config)
    report = {"file": str(path), "errors": [], "warnings": [], "info": {}}
    if not path.exists():
        report["errors"].append("file does not exist")
        print_report(report, args.json)
        return 2
    text = path.read_text(encoding="utf-8", errors="replace")
    data, code = load_yaml(path)
    if code:
        return code
    if not isinstance(data, dict):
        report["errors"].append("YAML root is not a mapping/object")
        print_report(report, args.json)
        return 2

    report["warnings"].extend(section_order_warnings(text))

    proxies = []
    for key in PROXY_KEYS:
        v = data.get(key)
        if isinstance(v, list):
            for item in v:
                if isinstance(item, dict) and item.get("name"):
                    proxies.append(str(item["name"]))
    proxy_set = set(proxies)

    providers = {}
    for key in PROVIDER_KEYS:
        v = data.get(key)
        if isinstance(v, dict):
            providers.update(v)
    provider_set = set(map(str, providers.keys()))

    groups = []
    group_defs = data.get("proxy-groups") or []
    if isinstance(group_defs, list):
        for g in group_defs:
            if isinstance(g, dict) and g.get("name"):
                groups.append(str(g["name"]))
    group_set = set(groups)

    rule_providers = data.get("rule-providers") or {}
    if not isinstance(rule_providers, dict):
        rule_providers = {}
    rule_provider_set = set(map(str, rule_providers.keys()))

    rules = data.get("rules") or []
    if not isinstance(rules, list):
        report["errors"].append("rules exists but is not a list")
        rules = []

    report["info"] = {
        "proxy_count": len(proxies),
        "proxy_provider_count": len(provider_set),
        "proxy_group_count": len(groups),
        "rule_provider_count": len(rule_provider_set),
        "rule_count": len(rules),
        "groups": groups[:120],
    }

    if not proxies and not provider_set:
        report["warnings"].append("No proxies or proxy-providers detected. Subscription may be empty or invalid.")
    if not groups:
        report["errors"].append("No proxy-groups detected.")
    if not rules:
        report["warnings"].append("No rules detected.")

    for name, count in Counter(groups).items():
        if count > 1:
            report["errors"].append(f"Duplicate proxy-group name: {name}")
    for name, count in Counter(proxies).items():
        if count > 1:
            report["warnings"].append(f"Duplicate proxy name: {name}")

    # group members and provider uses
    all_selectable = proxy_set | group_set | BUILTINS
    if isinstance(group_defs, list):
        for g in group_defs:
            if not isinstance(g, dict):
                continue
            gname = str(g.get("name", "<unnamed>"))
            for member in g.get("proxies") or []:
                member = str(member)
                if member not in all_selectable:
                    report["warnings"].append(f"Group '{gname}' references unknown proxy/group: {member}")
            for used in g.get("use") or []:
                used = str(used)
                if used not in provider_set:
                    report["warnings"].append(f"Group '{gname}' uses unknown proxy-provider: {used}")

    # rules target groups and rule-provider references
    missing_targets = set()
    missing_rule_providers = set()
    match_positions = []
    for idx, r in enumerate(rules):
        if not isinstance(r, str):
            report["warnings"].append(f"Rule #{idx+1} is not a string: {type(r).__name__}")
            continue
        parts = split_rule(r)
        rtype = parts[0].upper() if parts else ""
        if rtype == "MATCH":
            match_positions.append(idx)
        if rtype == "RULE-SET" and len(parts) >= 2:
            pname = parts[1]
            if pname not in rule_provider_set:
                missing_rule_providers.add(pname)
        target = rule_target(parts)
        if target and target not in group_set and target not in BUILTINS:
            # no-resolve is handled above; names starting with REJECT are sometimes valid.
            missing_targets.add(target)
    if missing_targets:
        report["errors"].append("Rules reference missing strategy groups: " + ", ".join(sorted(missing_targets)))
    if missing_rule_providers:
        report["errors"].append("RULE-SET references missing rule-providers: " + ", ".join(sorted(missing_rule_providers)))
    if match_positions:
        if match_positions[-1] != len(rules) - 1:
            report["warnings"].append("MATCH rule is not the final rule. Later rules will never be reached.")
        if len(match_positions) > 1:
            report["warnings"].append("Multiple MATCH rules found. Only the first effective MATCH usually matters.")

    dns = data.get("dns")
    if isinstance(dns, dict):
        listen = str(dns.get("listen", ""))
        enhanced = str(dns.get("enhanced-mode", ""))
        fake_filter = dns.get("fake-ip-filter") or []
        report["info"]["dns_listen"] = listen
        report["info"]["dns_enhanced_mode"] = enhanced
        if listen.endswith(":53") or listen == "0.0.0.0:53":
            report["warnings"].append("DNS listen is set to port 53; OpenClash may take over/translate this, but check dnsmasq port conflicts.")
        if enhanced.lower() == "fake-ip":
            ff = "\n".join(map(str, fake_filter)) if isinstance(fake_filter, list) else str(fake_filter)
            for needed in ("localhost", "*.lan", "*.local"):
                if needed not in ff:
                    report["warnings"].append(f"Fake-IP mode: fake-ip-filter may be missing local entry: {needed}")
    else:
        report["warnings"].append("No dns section detected; OpenClash may auto-add/override DNS, but audit generated config.")

    print_report(report, args.json)
    if report["errors"]:
        return 2
    if args.strict and report["warnings"]:
        return 1
    return 0


def print_report(report, as_json=False):
    if as_json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
        return
    print(f"# OpenClash config lint: {report['file']}")
    print("\n## Info")
    for k, v in report["info"].items():
        if isinstance(v, list):
            print(f"- {k}: {', '.join(v) if v else 'none'}")
        else:
            print(f"- {k}: {v}")
    print("\n## Errors")
    if report["errors"]:
        for e in report["errors"]:
            print(f"- ERROR: {e}")
    else:
        print("- none")
    print("\n## Warnings")
    if report["warnings"]:
        for w in report["warnings"]:
            print(f"- WARNING: {w}")
    else:
        print("- none")

if __name__ == "__main__":
    raise SystemExit(main())
