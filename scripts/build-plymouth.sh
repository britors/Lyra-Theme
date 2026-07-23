#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
dist=${1:-"$root/dist"}
theme_dir="$dist/plymouth/Lyra-Enterprise"

command -v im >/dev/null 2>&1 || { echo 'error: ImageMagick is required' >&2; exit 1; }

mkdir -p "$theme_dir"

im -background none "$root/src/plymouth/logo.svg" -resize 200% -strip \
  "$theme_dir/logo.png"
im -background none "$root/src/plymouth/progress-track.svg" -resize 200% -strip \
  "$theme_dir/progress-track.png"
im -background none "$root/src/plymouth/progress-fill.svg" -resize 200% -strip \
  "$theme_dir/progress-fill.png"

cp "$root/src/plymouth/lyra-enterprise.plymouth" "$theme_dir/"
cp "$root/src/plymouth/lyra-enterprise.script" "$theme_dir/"
