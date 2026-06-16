#!/usr/bin/env python3
"""Validate Agent Skill SKILL.md frontmatter."""

from __future__ import annotations

import re
import sys
from pathlib import Path

import yaml

NAME_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    if len(sys.argv) != 2:
        fail("usage: check_skill_frontmatter.py SKILL.md")

    path = Path(sys.argv[1])
    text = path.read_text(encoding="utf-8")

    if not text.startswith("---\n"):
        fail("SKILL.md must start with YAML frontmatter line '---'")

    parts = text.split("---\n", 2)
    if len(parts) < 3:
        fail("SKILL.md must contain closing YAML frontmatter line '---'")

    frontmatter = parts[1]
    try:
        metadata = yaml.safe_load(frontmatter)
    except yaml.YAMLError as exc:
        fail(f"frontmatter is not valid YAML: {exc}")

    if not isinstance(metadata, dict):
        fail("frontmatter must parse to a mapping")

    name = metadata.get("name")
    description = metadata.get("description")

    if not isinstance(name, str) or not name:
        fail("frontmatter requires a non-empty string field: name")
    if len(name) > 64:
        fail("name must be <= 64 characters")
    if not NAME_RE.match(name):
        fail("name must use lowercase letters, numbers, and single hyphens only")

    if not isinstance(description, str) or not description.strip():
        fail("frontmatter requires a non-empty string field: description")
    if len(description) > 1024:
        fail("description must be <= 1024 characters")

    print("SKILL.md frontmatter OK")


if __name__ == "__main__":
    main()
