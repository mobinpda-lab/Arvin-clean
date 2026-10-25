#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FONT_REVISION="83629f877e8f084cc07b47030b5d3a0ff06c76ec"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/arvin-vazirmatn.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
git clone --no-tags --no-checkout --filter=blob:none https://github.com/rastikerdar/vazirmatn.git "$WORK/source"
git -C "$WORK/source" fetch --depth 1 origin "$FONT_REVISION"
git -C "$WORK/source" checkout --detach "$FONT_REVISION"
test "$(git -C "$WORK/source" rev-parse HEAD)" = "$FONT_REVISION"
DEST="$ROOT/assets/fonts/vazirmatn"
mkdir -p "$DEST"
for weight in Light Regular Medium SemiBold Bold; do
  source_file="$WORK/source/fonts/ttf/Vazirmatn-$weight.ttf"
  test -s "$source_file"
  cp "$source_file" "$DEST/Vazirmatn-$weight.ttf"
done
cp "$WORK/source/OFL.txt" "$DEST/OFL.txt"
for weight in Regular Medium SemiBold Bold; do
  test -s "$DEST/Vazirmatn-$weight.ttf"
done
test -s "$DEST/OFL.txt"
echo "Vazirmatn assets verified at $FONT_REVISION"
