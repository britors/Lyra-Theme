#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
dist=${1:-"$root/dist"}
theme_dir="$dist/plymouth/Lyra-Enterprise"

command -v svg_to_png >/dev/null 2>&1 || { echo 'error: svg_to_png is required' >&2; exit 1; }

mkdir -p "$theme_dir"

svg_to_png "$root/src/plymouth/logo.svg" "$theme_dir/logo.png" 440 600
svg_to_png "$root/src/plymouth/progress-track.svg" \
  "$theme_dir/progress-track.png" 800 20
svg_to_png "$root/src/plymouth/progress-fill.svg" \
  "$theme_dir/progress-fill.png" 800 20

cp "$root/src/plymouth/lyra-enterprise.plymouth" "$theme_dir/"
cp "$root/src/plymouth/lyra-enterprise.script" "$theme_dir/"
