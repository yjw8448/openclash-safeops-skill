#!/usr/bin/env python3
"""Apply a safe template overlay to one OpenClash/Mihomo YAML config.

Default behavior is candidate-only and does not overwrite the target.

Usage:
  python3 openclash_template_apply.py --target /etc/openclash/config/config-a.yaml --template aethersailor-current-safe --candidate /tmp/config-a.aethersailor.yaml
  python3 openclash_template_apply.py --target /etc/openclash/config/config-a.yaml --template ffani-redirhost-smartdns --candidate /tmp/config-a.ffani.yaml
  I_UNDERSTAND_TARGETED_WRITE=1 python3 openclash_template_apply.py --target /etc/openclash/config/config-a.yaml --template ffani-redirhost-smartdns --candidate /tmp/config-a.ffani.yaml --apply
  python3 openclash_template_apply.py --target config.yaml --overlay-file templates/custom-overlay.yaml --candidate /tmp/config.candidate.yaml

Safety properties:
- Requires one explicit target YAML.
- Writes a candidate first by default.
- Refuses to modify protected sections: proxies, proxy-groups, proxy-providers, proxy-provider.
- Merges rules without duplicating and keeps MATCH last when possible.
- Does not touch /etc/config/network, /etc/config/dhcp, or /etc/config/firewall.
"""
from __future__ import annotations

import argparse
import difflib
import os
import shutil
import sys
from copy import deepcopy
from pathlib import Path
from typing import Any, Dict, Iterable, List

PROTECTED_TOP_LEVEL = {"proxies", "Proxy", "proxy-groups", "proxy-providers", "proxy-provider"}
SAFE_TOP_LEVEL = {"dns", "sniffer", "rules", "rule-providers", "tun", "profile", "geox-url", "geodata-mode", "geodata-loader"}

BT_PT_DIRECT_RULES = [
    "DOMAIN-SUFFIX,daydream.dmhy.best,DIRECT",
    "DOMAIN-SUFFIX,probe.skyey2.com,DIRECT",
    "DOMAIN-SUFFIX,jpopsuki.eu,DIRECT",
    "DOMAIN-SUFFIX,pt.btschool.club,DIRECT",
    "DOMAIN-SUFFIX,tracker.m-team.cc,DIRECT",
    "DOMAIN-SUFFIX,ipv6-tracker.m-team.cc,DIRECT",
    "DOMAIN-SUFFIX,tracker.52dic.vip,DIRECT",
]

AI_RULES_TEMPLATE = [
    "GEOSITE,openai,{CHATGPT_GROUP}",
    "GEOSITE,category-ai-!cn,{AI_GROUP}",
    "DOMAIN-SUFFIX,openai.com,{CHATGPT_GROUP}",
    "DOMAIN-SUFFIX,chatgpt.com,{CHATGPT_GROUP}",
    "DOMAIN-SUFFIX,anthropic.com,{AI_GROUP}",
    "DOMAIN-SUFFIX,claude.ai,{AI_GROUP}",
    "GEOSITE,github,{GITHUB_GROUP}",
    "DOMAIN-SUFFIX,github.com,{GITHUB_GROUP}",
    "DOMAIN-SUFFIX,githubusercontent.com,{GITHUB_GROUP}",
]

AETHERSAILOR_DIRECT_GEOSITE_RULES = [
    "GEOSITE,private,DIRECT",
    "GEOIP,private,DIRECT,no-resolve",
    "GEOSITE,google-cn,DIRECT",
    "GEOSITE,category-games@cn,DIRECT",
    "GEOSITE,category-game-platforms-download,DIRECT",
    "GEOSITE,category-public-tracker,DIRECT",
    "GEOSITE,cn,DIRECT",
    "GEOIP,CN,DIRECT,no-resolve",
]

AETHERSAILOR_SERVICE_RULES_TEMPLATE = [
    "GEOSITE,steam,{STEAM_GROUP}",
    "GEOSITE,youtube,{MEDIA_GROUP}",
    "GEOSITE,netflix,{MEDIA_GROUP}",
    "GEOSITE,disney,{MEDIA_GROUP}",
    "GEOSITE,tiktok,{MEDIA_GROUP}",
    "GEOSITE,category-entertainment,{MEDIA_GROUP}",
    "GEOSITE,category-communication,{PROXY_GROUP}",
    "GEOSITE,category-social-media-!cn,{PROXY_GROUP}",
    "GEOSITE,gfw,{PROXY_GROUP}",
]

PRIVATE_DIRECT_RULES = [
    "IP-CIDR,10.0.0.0/8,DIRECT,no-resolve",
    "IP-CIDR,172.16.0.0/12,DIRECT,no-resolve",
    "IP-CIDR,192.168.0.0/16,DIRECT,no-resolve",
    "IP-CIDR,127.0.0.0/8,DIRECT,no-resolve",
    "IP-CIDR6,fc00::/7,DIRECT,no-resolve",
    "IP-CIDR6,fe80::/10,DIRECT,no-resolve",
]

CN_DIRECT_RULES = [
    "GEOSITE,private,DIRECT",
    "GEOSITE,cn,DIRECT",
    "GEOIP,CN,DIRECT",
]


def load_yaml(path: Path) -> Any:
    try:
        import yaml  # type: ignore
    except Exception as exc:
        raise SystemExit("ERROR: Python module 'yaml' is missing. Install PyYAML or run this on a machine that has it. detail: %s" % exc)
    with path.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def dump_yaml(data: Any, path: Path) -> None:
    try:
        import yaml  # type: ignore
    except Exception as exc:
        raise SystemExit("ERROR: Python module 'yaml' is missing. detail: %s" % exc)
    with path.open("w", encoding="utf-8") as f:
        yaml.safe_dump(data, f, allow_unicode=True, sort_keys=False, default_flow_style=False)


def ensure_mapping(data: Any, label: str) -> Dict[str, Any]:
    if not isinstance(data, dict):
        raise SystemExit(f"ERROR: {label} root is not a YAML mapping/object")
    return data


def top_level_groups(data: Dict[str, Any]) -> List[str]:
    groups = []
    for g in data.get("proxy-groups") or []:
        if isinstance(g, dict) and g.get("name"):
            groups.append(str(g["name"]))
    return groups


def choose_group(groups: List[str], role: str) -> str:
    patterns = {
        "CHATGPT_GROUP": ["chatgpt", "openai", "🤖", "ai"],
        "AI_GROUP": ["ai服务", "ai", "claude", "anthropic", "🤖"],
        "GITHUB_GROUP": ["github", "git"],
        "STEAM_GROUP": ["steam", "游戏平台", "游戏"],
        "MEDIA_GROUP": ["国外媒体", "media", "youtube", "netflix", "流媒体"],
        "PROXY_GROUP": ["proxy", "节点", "选择", "手动", "select", "🚀", "国外"],
        "FINAL_GROUP": ["final", "match", "漏网", "兜底", "🐟"],
    }
    lower = [(g.lower(), g) for g in groups]
    for pat in patterns.get(role, []):
        p = pat.lower()
        for lg, g in lower:
            if p in lg:
                return g
    # fallbacks: specialized groups should prefer main proxy group rather than inventing names.
    if role in {"CHATGPT_GROUP", "AI_GROUP", "GITHUB_GROUP", "STEAM_GROUP", "MEDIA_GROUP"}:
        return choose_group(groups, "PROXY_GROUP")
    return groups[0] if groups else "Proxy"


def insert_rules_before_match(existing: Any, additions: Iterable[str]) -> List[str]:
    rules = [] if existing is None else list(existing if isinstance(existing, list) else [])
    # Keep only string rules plus non-string as-is at the end of the prefix.
    text_rules = [r for r in rules if isinstance(r, str)]
    seen = set(text_rules)
    add = [r for r in additions if r not in seen]
    if not add:
        return rules
    match_index = None
    for i, r in enumerate(rules):
        if isinstance(r, str) and r.strip().upper().startswith("MATCH"):
            match_index = i
            break
    if match_index is None:
        return rules + add
    return rules[:match_index] + add + rules[match_index:]


def recursive_merge(base: Dict[str, Any], overlay: Dict[str, Any], changed: List[str]) -> Dict[str, Any]:
    for key, value in overlay.items():
        if key in PROTECTED_TOP_LEVEL:
            raise SystemExit(f"ERROR: overlay attempts to modify protected section '{key}'. Refuse to continue.")
        if key not in SAFE_TOP_LEVEL:
            raise SystemExit(f"ERROR: overlay attempts to modify unsupported top-level section '{key}'. Allowed: {', '.join(sorted(SAFE_TOP_LEVEL))}")
        if key == "rules":
            base[key] = insert_rules_before_match(base.get(key), value if isinstance(value, list) else [])
            changed.append("rules")
        elif isinstance(value, dict) and isinstance(base.get(key), dict):
            merged = deepcopy(base[key])
            merged.update(value)
            base[key] = merged
            changed.append(key)
        else:
            base[key] = deepcopy(value)
            changed.append(key)
    return base


def built_in_overlay(template: str, data: Dict[str, Any], args) -> Dict[str, Any]:
    groups = top_level_groups(data)
    proxy_group = args.proxy_group or choose_group(groups, "PROXY_GROUP")
    ai_group = args.ai_group or choose_group(groups, "AI_GROUP")

    if template in {"aethersailor-current-safe", "aethersailor-legacy-safe"}:
        chatgpt_group = args.chatgpt_group or choose_group(groups, "CHATGPT_GROUP")
        github_group = args.github_group or choose_group(groups, "GITHUB_GROUP")
        steam_group = args.steam_group or choose_group(groups, "STEAM_GROUP")
        media_group = args.media_group or choose_group(groups, "MEDIA_GROUP")
        ai_rules = [r.format(AI_GROUP=ai_group, CHATGPT_GROUP=chatgpt_group, GITHUB_GROUP=github_group, PROXY_GROUP=proxy_group) for r in AI_RULES_TEMPLATE]
        service_rules = [r.format(PROXY_GROUP=proxy_group, STEAM_GROUP=steam_group, MEDIA_GROUP=media_group) for r in AETHERSAILOR_SERVICE_RULES_TEMPLATE]
        return {
            "dns": {
                "enable": True,
                "listen": "127.0.0.1:7874",
                "ipv6": True,
                "enhanced-mode": "fake-ip",
                "fake-ip-range": "198.18.0.1/16",
                "respect-rules": True,
                "use-hosts": True,
                "fake-ip-filter": [
                    "*.lan",
                    "*.local",
                    "localhost",
                    "localhost.ptlogin2.qq.com",
                    "+.msftconnecttest.com",
                    "+.msftncsi.com",
                    "+.router.asus.com",
                    "+.miwifi.com",
                    "+.tplinkwifi.net",
                    "+.home.arpa",
                ],
                "nameserver": ["system"],
                "fallback": [],
                "default-nameserver": [],
            },
            "sniffer": {
                "enable": True,
                "force-dns-mapping": True,
                "parse-pure-ip": True,
                "override-destination": True,
                "sniff": {
                    "HTTP": {"ports": [80, "8080-8880"], "override-destination": True},
                    "TLS": {"ports": [443, 8443]},
                    "QUIC": {"ports": [443, 8443]},
                },
            },
            "geodata-mode": True,
            "rules": PRIVATE_DIRECT_RULES + AETHERSAILOR_DIRECT_GEOSITE_RULES + BT_PT_DIRECT_RULES + ai_rules + service_rules,
        }

    if template == "ffani-redirhost-smartdns":
        return {
            "dns": {
                "enable": True,
                "listen": "127.0.0.1:7874",
                "ipv6": True,
                "enhanced-mode": "redir-host",
                "prefer-h3": False,
                "respect-rules": True,
                "use-hosts": True,
                "nameserver-policy": {
                    "geosite:cn,private,apple": ["127.0.0.1:6053"],
                    "geoip:private": ["127.0.0.1:6053"],
                },
                "nameserver": ["127.0.0.1:6553"],
                "fallback": [],
                "default-nameserver": [],
            },
            "sniffer": {
                "enable": True,
                "force-dns-mapping": True,
                "parse-pure-ip": True,
                "override-destination": True,
                "sniff": {
                    "HTTP": {"ports": [80, "8080-8880"], "override-destination": True},
                    "TLS": {"ports": [443, 8443]},
                    "QUIC": {"ports": [443, 8443]},
                },
            },
            "rules": BT_PT_DIRECT_RULES,
        }
    if template == "minimal-safe":
        return {
            "dns": {
                "enable": True,
                "listen": "127.0.0.1:7874",
                "ipv6": True,
                "enhanced-mode": "redir-host",
                "respect-rules": True,
            },
            "sniffer": {"enable": True, "parse-pure-ip": True, "override-destination": True},
        }
    if template == "ai-dev-rules":
        chatgpt_group = args.chatgpt_group or choose_group(groups, "CHATGPT_GROUP")
        github_group = args.github_group or choose_group(groups, "GITHUB_GROUP")
        rules = [r.format(AI_GROUP=ai_group, CHATGPT_GROUP=chatgpt_group, GITHUB_GROUP=github_group, PROXY_GROUP=proxy_group) for r in AI_RULES_TEMPLATE]
        return {"rules": rules}
    raise SystemExit(f"ERROR: unknown template: {template}")


def safe_diff(old_text: str, new_text: str, old_label: str, new_label: str, max_lines: int) -> str:
    lines = list(difflib.unified_diff(old_text.splitlines(), new_text.splitlines(), fromfile=old_label, tofile=new_label, lineterm=""))
    if len(lines) > max_lines:
        lines = lines[:max_lines] + [f"... diff truncated, total lines={len(lines)}"]
    return "\n".join(lines)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--target", required=True, help="one explicit /etc/openclash/config/*.yaml target")
    ap.add_argument("--template", default="ffani-redirhost-smartdns", choices=["aethersailor-current-safe", "aethersailor-legacy-safe", "ffani-redirhost-smartdns", "minimal-safe", "ai-dev-rules"], help="built-in safe template profile")
    ap.add_argument("--overlay-file", help="safe YAML overlay file; protected sections are refused")
    ap.add_argument("--candidate", required=True, help="candidate output path")
    ap.add_argument("--apply", action="store_true", help="overwrite target with candidate; requires I_UNDERSTAND_TARGETED_WRITE=1")
    ap.add_argument("--ai-group", help="real strategy group name for AI rules")
    ap.add_argument("--chatgpt-group", help="real strategy group name for ChatGPT/OpenAI rules")
    ap.add_argument("--github-group", help="real strategy group name for GitHub rules")
    ap.add_argument("--steam-group", help="real strategy group name for Steam/gaming rules")
    ap.add_argument("--media-group", help="real strategy group name for media/streaming rules")
    ap.add_argument("--proxy-group", help="real strategy group name for proxy rules")
    ap.add_argument("--diff-lines", type=int, default=160)
    args = ap.parse_args()

    target = Path(args.target)
    candidate = Path(args.candidate)
    if not target.exists():
        raise SystemExit(f"ERROR: target does not exist: {target}")
    if target.suffix.lower() not in {".yaml", ".yml"}:
        raise SystemExit("ERROR: target must be a YAML file")
    if "/etc/openclash/config/" not in str(target):
        print("WARN: target is not under /etc/openclash/config/. Continue only if this is a local dry-run copy.")

    old_text = target.read_text(encoding="utf-8", errors="replace")
    data = ensure_mapping(load_yaml(target), "target")
    before_protected = {k: deepcopy(data.get(k)) for k in PROTECTED_TOP_LEVEL if k in data}

    changed: List[str] = []
    if args.overlay_file:
        overlay = ensure_mapping(load_yaml(Path(args.overlay_file)), "overlay")
    else:
        overlay = built_in_overlay(args.template, data, args)
    new_data = recursive_merge(deepcopy(data), overlay, changed)

    for k, before in before_protected.items():
        if new_data.get(k) != before:
            raise SystemExit(f"ERROR: protected section changed unexpectedly: {k}")

    candidate.parent.mkdir(parents=True, exist_ok=True)
    dump_yaml(new_data, candidate)
    new_text = candidate.read_text(encoding="utf-8", errors="replace")

    print("===== Template apply summary =====")
    print(f"target={target}")
    print(f"candidate={candidate}")
    print(f"template={args.template}")
    if args.overlay_file:
        print(f"overlay_file={args.overlay_file}")
    print("changed_sections=" + ",".join(sorted(set(changed))))
    print("protected_sections_preserved=" + ",".join(sorted(before_protected.keys())))
    print(f"target_sha256_before={os.popen('sha256sum ' + repr(str(target))).read().split()[0] if target.exists() else ''}")
    print(f"candidate_sha256={os.popen('sha256sum ' + repr(str(candidate))).read().split()[0] if candidate.exists() else ''}")
    print("===== Diff preview =====")
    print(safe_diff(old_text, new_text, str(target), str(candidate), args.diff_lines))

    if args.apply:
        if os.environ.get("I_UNDERSTAND_TARGETED_WRITE") != "1":
            raise SystemExit("ERROR: --apply requires I_UNDERSTAND_TARGETED_WRITE=1")
        # Candidate has already been generated. Copy only the candidate to exactly the target.
        shutil.copy2(candidate, target)
        print("APPLIED=1")
        print(f"wrote_target={target}")
    else:
        print("APPLIED=0")
        print("NEXT: lint the candidate, verify target binding, show this diff to the user, then apply only after explicit approval.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
