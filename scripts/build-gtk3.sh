#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
dist=${1:-"$root/dist"}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

compile() {
  local tokens=$1 output=$2 input="$tmp/input.scss"
  { cat "$tokens"; cat "$root/src/gtk3/gtk.scss"; } > "$input"
  if command -v sassc >/dev/null 2>&1; then
    sassc --style expanded --sourcemap=none "$input" "$output"
  else
    cp "$root/src/gtk3/gtk.scss" "$output"
    while IFS= read -r line; do
      [[ $line =~ ^\$([a-zA-Z0-9_-]+):[[:space:]]*(.*)\;$ ]] || continue
      name=${BASH_REMATCH[1]}; value=${BASH_REMATCH[2]}
      sed -i "s|#{\$$name}|$value|g; s|\$$name|$value|g" "$output"
    done < "$tokens"
  fi
}

mkdir -p "$dist/Lyra-Enterprise/gtk-3.0" "$dist/Lyra-Enterprise-Light/gtk-3.0"
compile "$root/src/gtk3/_colors-dark.scss" "$dist/Lyra-Enterprise/gtk-3.0/gtk.css"
compile "$root/src/gtk3/_colors-light.scss" "$dist/Lyra-Enterprise-Light/gtk-3.0/gtk.css"
for variant in Lyra-Enterprise Lyra-Enterprise-Light; do
  cp "$root/src/gtk3/ATTRIBUTION.md" "$dist/$variant/gtk-3.0/"
  cp "$root/src/gtk3/COPYING.LGPL" "$dist/$variant/gtk-3.0/"
done
