#!/usr/bin/env python3
"""Taps an element by its accessibility label, scrolling it on screen first.

`axe tap --label` taps the element's centre wherever that is — including
below the screen, where the tap lands on the address bar or on nothing at
all, and reports success either way. VoiceOver scrolls to whatever it
focuses before activating it; this does the same.

    ./Scripts/voiceover-tap.py "Buscar vuelos" [--udid UDID] [--type Button] [--no-scroll]

`--no-scroll` taps wherever the element is: for the address bar and its
buttons, which sit below the content and are always on screen.
"""

import json
import subprocess
import sys
import time

SCREEN_TOP = 110      # below the status bar and any sticky header
SCREEN_BOTTOM = 760   # above the address bar


def run(args):
    return subprocess.run(args, capture_output=True, text=True)


def elements(udid):
    cmd = ["axe", "describe-ui"]
    if udid:
        cmd += ["--udid", udid]
    tree = json.loads(run(cmd).stdout)
    found = []

    def walk(node):
        if isinstance(node, list):
            for child in node:
                walk(child)
            return
        found.append(node)
        for child in node.get("children") or []:
            walk(child)

    walk(tree)
    return found


def locate(label, kind, udid):
    for node in elements(udid):
        if kind and node.get("type") != kind:
            continue
        if node.get("AXLabel") == label:
            frame = node.get("frame") or {}
            return frame["x"] + frame["width"] / 2, frame["y"] + frame["height"] / 2
    return None


def swipe(udid, from_y, to_y):
    # A slow drag, not a flick: a flick keeps the scroll view decelerating
    # for a couple of seconds, and a tap that lands meanwhile only stops it.
    cmd = ["axe", "swipe", "--start-x", "200", "--start-y", str(from_y),
           "--end-x", "200", "--end-y", str(to_y), "--duration", "1.0"]
    if udid:
        cmd += ["--udid", udid]
    run(cmd)
    time.sleep(0.8)


def settled(label, kind, udid, point):
    """True once the element stays put between two readings."""
    time.sleep(0.5)
    again = locate(label, kind, udid)
    return again is not None and abs(again[1] - point[1]) < 1


def main():
    args = sys.argv[1:]
    udid = args[args.index("--udid") + 1] if "--udid" in args else None
    kind = args[args.index("--type") + 1] if "--type" in args else None
    anywhere = "--no-scroll" in args
    label = args[0]

    for _ in range(8):
        point = locate(label, kind, udid)
        if point is None:
            print(f"no hay elemento con etiqueta {label!r}", file=sys.stderr)
            sys.exit(1)
        x, y = point
        if anywhere or SCREEN_TOP <= y <= SCREEN_BOTTOM:
            if not anywhere and not settled(label, kind, udid, point):
                continue
            cmd = ["axe", "tap", "-x", str(x), "-y", str(y)]
            if udid:
                cmd += ["--udid", udid]
            run(cmd)
            print(f"tocado {label!r} en ({x:.0f}, {y:.0f})")
            return
        # Bring it towards the middle of the screen, one swipe at a time.
        # Swipes start high on the screen: a swipe that begins over the
        # keyboard, when a field has focus, scrolls nothing.
        if y > SCREEN_BOTTOM:
            delta = min(280, y - 430)
            swipe(udid, 420, 420 - delta)
        else:
            delta = min(280, 430 - y)
            swipe(udid, 140, 140 + delta)

    print(f"no pude traer {label!r} a la pantalla", file=sys.stderr)
    sys.exit(1)


if __name__ == "__main__":
    main()
