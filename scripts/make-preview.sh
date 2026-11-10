#!/usr/bin/env bash
# Turn a screenshot into the 600x400 PNG preview image the stores expect.
# Crops the centre of the input to 3:2, then scales to 600x400 and writes image.png.
# Usage: scripts/make-preview.sh <screenshot.png> [output.png]
set -euo pipefail
IN="${1:?usage: make-preview.sh <screenshot.png> [output.png]}"
OUT="${2:-$(cd "$(dirname "$0")/.." && pwd)/image.png}"
W=$(sips -g pixelWidth "$IN" | awk '/pixelWidth/ {print $2}')
H=$(sips -g pixelHeight "$IN" | awk '/pixelHeight/ {print $2}')
# target aspect 3:2
if (( W * 2 > H * 3 )); then CW=$(( H * 3 / 2 )); CH=$H; else CW=$W; CH=$(( W * 2 / 3 )); fi
cp "$IN" "$OUT.tmp.png"
sips -c "$CH" "$CW" "$OUT.tmp.png" --out "$OUT.tmp.png" >/dev/null   # centre crop
sips -z 400 600 "$OUT.tmp.png" --out "$OUT" >/dev/null              # scale
rm -f "$OUT.tmp.png"
echo "Wrote $OUT ($(sips -g pixelWidth -g pixelHeight "$OUT" | awk '/pixel/ {printf "%s ", $2}'))"
