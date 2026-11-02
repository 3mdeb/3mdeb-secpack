#!/usr/bin/env python3
# upstream-advisories.py - render the upstream advisories table from YAML
#
# Usage:
#   ./scripts/upstream-advisories.py          # rewrite the generated part
#   ./scripts/upstream-advisories.py --check  # exit 1 if it is out of date
#
# Reads upstream-advisories/upstream-advisories.yml and replaces the text
# between the BEGIN/END markers in upstream-advisories/README.md. Exits 1
# when the file had to change, so the pre-commit hook fails until the
# regenerated README.md is staged. Requires PyYAML.

import os
import sys
import textwrap

import yaml

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(REPO_ROOT, "upstream-advisories", "upstream-advisories.yml")
PAGE = os.path.join(REPO_ROOT, "upstream-advisories", "README.md")
BEGIN = "<!-- BEGIN generated from upstream-advisories.yml, do not edit -->"
END = "<!-- END generated -->"
FIELDS = ("advisory", "url", "cve", "upstream", "component", "published",
          "checked", "current", "earlier", "dsb", "why", "evidence")


def yes_no(value):
    if not isinstance(value, bool):
        raise ValueError(f"expected yes/no, got {value!r}")
    return "Yes" if value else "No"


def dsb_link(dsb):
    """dsb-003-2026 -> [DSB-003](../DSBs/dsb-003-2026.txt)"""
    if not dsb:
        return "-"
    return f"[{dsb.rsplit('-', 1)[0].upper()}](../DSBs/{dsb}.txt)"


def render(entries):
    out = [
        "| Advisory | CVE | Upstream | Published | Current releases "
        "| Earlier releases | DSB | Checked |",
        "|---|---|---|---|---|---|---|---|",
    ]
    for e in entries:
        missing = [f for f in FIELDS if f not in e]
        if missing:
            raise ValueError(f"{e.get('advisory', '?')}: missing {missing}")
        out.append(" | ".join([
            f"| [{e['advisory']}]({e['url']})",
            e["cve"] or "-",
            f"{e['upstream']} ({e['component']})",
            str(e["published"]),
            yes_no(e["current"]),
            yes_no(e["earlier"]),
            dsb_link(e["dsb"]),
            f"{e['checked']} |",
        ]))
    for e in entries:
        out += ["", f"### {e['advisory']}", ""]
        out += textwrap.wrap(" ".join(e["why"].split()), 79)
        out += ["", f"Evidence: <{e['evidence']}>"]
    return "\n".join(out)


def main():
    check = sys.argv[1:] == ["--check"]
    with open(DATA) as f:
        entries = yaml.safe_load(f)
    with open(PAGE) as f:
        page = f.read()
    head, sep, rest = page.partition(BEGIN + "\n")
    _, sep2, tail = rest.partition(END)
    if not sep or not sep2:
        sys.exit(f"{PAGE}: BEGIN/END markers not found")
    new = head + BEGIN + "\n" + render(entries) + "\n" + END + tail
    if new == page:
        return 0
    if not check:
        with open(PAGE, "w") as f:
            f.write(new)
        print(f"updated {os.path.relpath(PAGE, REPO_ROOT)}")
    else:
        print(f"{os.path.relpath(PAGE, REPO_ROOT)} is out of date")
    return 1


if __name__ == "__main__":
    sys.exit(main())
