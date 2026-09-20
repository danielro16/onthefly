#!/bin/zsh
# Opens a URL in JEF Browser on the simulator, the way a person would: tap the
# address bar, paste, go. Pasting rather than typing because `axe type` sends
# US keycodes and the simulator's Spanish keyboard mangles `/` and `?`.
#
#   ./Scripts/open-url.sh https://example.com [seconds-to-wait]
#
# UDID=... overrides the simulator. Relaunches the app first so every run
# starts from the same place.

set -u
U=${UDID:-233986A3-851C-4FA3-83AF-0A64E047E60C}
URL=$1
WAIT=${2:-25}
cd "$(dirname "$0")/.."

xcrun simctl terminate "$U" ai.jef.browser 2>/dev/null
sleep 2
xcrun simctl launch "$U" ai.jef.browser >/dev/null
sleep 4

printf '%s' "$URL" | xcrun simctl pbcopy "$U"
axe tap -x 201 -y 811 --udid "$U" >/dev/null       # the address bar
axe key-combo --modifiers 227 --key 4 --udid "$U" >/dev/null   # cmd+A
axe key-combo --modifiers 227 --key 25 --udid "$U" >/dev/null  # cmd+V
sleep 1
axe key 40 --udid "$U" >/dev/null                  # return
sleep "$WAIT"
./Scripts/voiceover-walk.py --udid "$U"
