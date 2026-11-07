"""Cuts the recording into clips, frames each in a drawn device bezel, and
writes them as animated WebPs: doc/demos/<clip>-<kind>.webp.

Called by tool/record_demos.sh.
"""

import argparse
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw

FPS = 15
# Width of the screen inside the bezel, in pixels.
SCREEN_WIDTH = {"iphone": 340, "ipad": 600}
# A little either side of each clip's markers, in seconds.
PAD = 0.15

BODY = (17, 17, 19, 255)
RIM = (58, 58, 60, 255)


def read_clips(markers: Path) -> list[tuple[str, float, float]]:
    starts: dict[str, float] = {}
    clips = []
    for line in markers.read_text().splitlines():
        edge, name, seconds = line.split()
        if edge == "start":
            starts[name] = float(seconds)
        elif name in starts:
            clips.append((name, starts.pop(name), float(seconds)))
    return clips


def extract_frames(video: Path, start: float, end: float, kind: str, into: Path):
    shutil.rmtree(into, ignore_errors=True)
    into.mkdir(parents=True)
    filters = [f"fps={FPS}"]
    # The iPad is recorded in its portrait buffer while the app runs in
    # landscape, turned a quarter clockwise, so turn it back.
    if kind == "ipad":
        filters.insert(0, "transpose=2")
    filters.append(f"scale={SCREEN_WIDTH[kind]}:-2:flags=lanczos")
    subprocess.run(
        [
            "ffmpeg", "-loglevel", "error", "-y",
            "-ss", f"{max(start - PAD, 0):.3f}",
            "-to", f"{end + PAD:.3f}",
            "-i", str(video),
            "-vf", ",".join(filters),
            str(into / "%04d.png"),
        ],
        check=True,
    )
    return sorted(into.glob("*.png"))


def bezel(size: tuple[int, int], kind: str):
    """The frame drawn around a screen of [size], and where the screen sits."""
    width, height = size
    short = min(width, height)
    if kind == "iphone":
        radius, border = round(0.135 * width), round(0.045 * width)
    else:
        radius, border = round(0.03 * short), round(0.035 * short)

    frame = Image.new("RGBA", (width + 2 * border, height + 2 * border))
    draw = ImageDraw.Draw(frame)
    draw.rounded_rectangle(
        (0, 0, frame.width - 1, frame.height - 1),
        radius=radius + border,
        fill=BODY,
        outline=RIM,
        width=max(1, border // 6),
    )

    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, width - 1, height - 1), radius=radius, fill=255
    )
    return frame, mask, border


def dynamic_island(screen: Image.Image) -> None:
    width = screen.width
    island_width, island_height = 0.31 * width, 0.088 * width
    left = (width - island_width) / 2
    top = 0.027 * width
    ImageDraw.Draw(screen).rounded_rectangle(
        (left, top, left + island_width, top + island_height),
        radius=island_height / 2,
        fill=(0, 0, 0, 255),
    )


def frame_clip(frames: list[Path], kind: str, into: Path) -> list[Path]:
    first = Image.open(frames[0])
    template, mask, border = bezel(first.size, kind)
    framed = []
    for path in frames:
        screen = Image.open(path).convert("RGBA")
        if kind == "iphone":
            dynamic_island(screen)
        out = template.copy()
        out.paste(screen, (border, border), mask)
        target = into / f"framed_{path.name}"
        out.save(target)
        framed.append(target)
    return framed


def to_webp(frames: list[Path], out: Path) -> None:
    delay = round(1000 / FPS)
    args = ["img2webp", "-loop", "0", "-lossy", "-q", "70", "-m", "6"]
    for frame in frames:
        args += ["-d", str(delay), str(frame)]
    args += ["-o", str(out)]
    subprocess.run(args, check=True, capture_output=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--kind", choices=["iphone", "ipad"], required=True)
    parser.add_argument("--video", type=Path, required=True)
    parser.add_argument("--markers", type=Path, required=True)
    parser.add_argument("--frames", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()

    for name, start, end in read_clips(args.markers):
        work = args.frames / name
        frames = extract_frames(args.video, start, end, args.kind, work)
        framed = frame_clip(frames, args.kind, work)
        out = args.out / f"{name}-{args.kind}.webp"
        to_webp(framed, out)
        print(f"{out.name}: {len(frames)} frames, {out.stat().st_size // 1024} KB")


if __name__ == "__main__":
    main()
