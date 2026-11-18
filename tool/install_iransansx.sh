#!/usr/bin/env bash
set -euo pipefail

archive="${1:-}"
if [[ -z "$archive" || ! -f "$archive" ]]; then
  echo "Usage: bash tool/install_iransansx.sh /path/to/IranSansX(Eco).zip" >&2
  exit 2
fi

mkdir -p assets/fonts

unzip -p "$archive" \
  'IranSansX(Eco)/Farsi numerals/IRANSansXFaNum-Regular.ttf' \
  > assets/fonts/IRANSansXFaNum-Regular.ttf

unzip -p "$archive" \
  'IranSansX(Eco)/Farsi numerals/IRANSansXFaNum-Bold.ttf' \
  > assets/fonts/IRANSansXFaNum-Bold.ttf

for file in \
  assets/fonts/IRANSansXFaNum-Regular.ttf \
  assets/fonts/IRANSansXFaNum-Bold.ttf; do
  if [[ ! -s "$file" ]]; then
    echo "Failed to extract $file" >&2
    exit 1
  fi
done

echo "Licensed IRANSansX FaNum Regular/Bold installed in assets/fonts."
echo "These binary files are intentionally ignored by Git."
