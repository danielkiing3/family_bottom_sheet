#!/usr/bin/env bash
# Records the README demo clips on a simulator and turns them into framed WebPs
# in doc/demos.
#
#   tool/record_demos.sh iphone
#   tool/record_demos.sh ipad
#
# Needs Xcode's simulators, ffmpeg, img2webp and Python 3 with Pillow.
set -euo pipefail

kind="${1:?usage: tool/record_demos.sh iphone|ipad}"
case "$kind" in
  iphone) device="iPhone 17 Pro" ;;
  ipad) device="iPad Pro 11-inch (M4)" ;;
  *) echo "kind must be iphone or ipad" >&2; exit 1 ;;
esac

root="$(cd "$(dirname "$0")/.." && pwd)"
work="$root/build/demos/$kind"
mkdir -p "$work" "$root/doc/demos"

udid="$(xcrun simctl list devices available -j | python3 -c "
import json, sys
for runtime in json.load(sys.stdin)['devices'].values():
    for d in runtime:
        if d['name'] == '$device':
            print(d['udid']); sys.exit()
")"
[ -n "$udid" ] || { echo "No simulator named $device" >&2; exit 1; }

xcrun simctl boot "$udid" 2>/dev/null || true
open -a Simulator
xcrun simctl bootstatus "$udid" -b >/dev/null

echo "Recording $device..."
xcrun simctl io "$udid" recordVideo --codec=h264 --force "$work/raw.mp4" \
  >"$work/record.log" 2>&1 &
recorder=$!
# Stop the recorder however the run ends, so the video is always finished.
stop_recording() { kill -INT "$recorder" 2>/dev/null && wait "$recorder" || true; }
trap stop_recording EXIT
until grep -q "Recording started" "$work/record.log" 2>/dev/null; do sleep 0.1; done
started="$(python3 -c 'import time; print(time.time())')"

(
  cd "$root/example"
  flutter test integration_test/demo_test.dart -d "$udid" \
    --dart-define=DEMO_MODE=true
) 2>&1 | python3 "$root/tool/demo_markers.py" "$started" >"$work/markers.txt"

stop_recording

python3 "$root/tool/make_demo_clips.py" \
  --kind "$kind" \
  --video "$work/raw.mp4" \
  --markers "$work/markers.txt" \
  --frames "$work/frames" \
  --out "$root/doc/demos"
