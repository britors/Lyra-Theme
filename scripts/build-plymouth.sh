#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
dist=${1:-"$root/dist"}
theme_dir="$dist/plymouth/Lyra-OS"
dracut_dir="$dist/dracut/51lyra-plymouth"

command -v svg_to_png >/dev/null 2>&1 || { echo 'error: svg_to_png is required' >&2; exit 1; }

mkdir -p "$theme_dir" "$dracut_dir"

svg_to_png "$root/src/gdm/logo.svg" "$theme_dir/watermark.png" 360 88

cp "$root/src/plymouth/lyra-os.plymouth" \
  "$theme_dir/Lyra-OS.plymouth"
install -m 0755 "$root/src/plymouth/dracut/module-setup.sh" \
  "$dracut_dir/module-setup.sh"
