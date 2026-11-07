"""Turns the demo test's clip markers into times in the recording.

Reads `flutter test` output on stdin, echoes it to stderr so progress shows,
and prints `start|end <clip> <seconds into the recording>` for every marker.
"""

import re
import sys
import time

started = float(sys.argv[1])
marker = re.compile(r"DEMO_CLIP_(START|END) (\S+)")

for line in sys.stdin:
    sys.stderr.write(line)
    found = marker.search(line)
    if found:
        edge, name = found.groups()
        print(f"{edge.lower()} {name} {time.time() - started:.3f}", flush=True)
