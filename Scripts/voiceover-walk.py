#!/usr/bin/env python3
"""Prints what VoiceOver would say, in the order it would say it.

The simulator cannot run VoiceOver, but its accessibility tree is what
VoiceOver reads from. This walks that tree (via `axe describe-ui`) and prints
one line per stop: role, label, value, hint. Reading this top to bottom is the
closest thing to hearing the page.

    ./Scripts/voiceover-walk.py [--udid UDID]

Counts stops and headings at the end, because those are the numbers the
project measures itself by.
"""

import json
import subprocess
import sys

ROLE = {
    "AXHeading": "H",
    "AXButton": "btn",
    "AXStaticText": "txt",
    "AXTextField": "field",
    "AXLink": "link",
    "AXImage": "img",
    "AXGroup": "grp",
    "AXApplication": "app",
}


def describe(udid):
    cmd = ["axe", "describe-ui"]
    if udid:
        cmd += ["--udid", udid]
    out = subprocess.run(cmd, capture_output=True, text=True, check=True).stdout
    return json.loads(out)


def walk(node, out):
    if isinstance(node, list):
        for child in node:
            walk(child, out)
        return
    if node.get("role") != "AXApplication":
        out.append(node)
    for child in node.get("children", []) or []:
        walk(child, out)


def clean(value):
    return None if value in (None, "None", "") else value


def main():
    udid = None
    if "--udid" in sys.argv:
        udid = sys.argv[sys.argv.index("--udid") + 1]

    stops = []
    walk(describe(udid), stops)

    headings = 0
    for i, n in enumerate(stops, 1):
        role = ROLE.get(n.get("role"), n.get("role"))
        if role == "H":
            headings += 1
        label = clean(n.get("AXLabel")) or "(sin etiqueta)"
        value = clean(n.get("AXValue"))
        hint = clean(n.get("help"))
        line = f"{i:3d} [{role}] {label}"
        if value:
            line += f"  = {value}"
        if hint:
            line += f"  ({hint})"
        print(line)

    print(f"\n{len(stops)} paradas, {headings} encabezados")


if __name__ == "__main__":
    main()
