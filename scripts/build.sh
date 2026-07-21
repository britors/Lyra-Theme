#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
dist="$root/dist"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

compile_scss() {
  local tokens=$1 source=$2 output=$3
  if command -v sassc >/dev/null 2>&1; then
    { sed '/^\/\//d' "$tokens"; cat "$source"; } > "$tmp/input.scss"
    sassc --style expanded "$tmp/input.scss" "$output"
    return
  fi

  # Minimal deterministic fallback for release builders without sassc. Sources
  # intentionally use only variables supported here; Arch packaging uses sassc.
  cp "$source" "$output"
  # Replace longer variable names first so, for example, $ent-surface does
  # not corrupt $ent-surface-raised. A second pass resolves token aliases.
  for _ in 1 2; do
    while IFS= read -r line; do
      [[ $line =~ ^\$([a-zA-Z0-9_-]+):[[:space:]]*(.*)\;$ ]] || continue
      name=${BASH_REMATCH[1]}
      value=${BASH_REMATCH[2]}
      sed -i "s|#{\$$name}|$value|g; s|\$$name|$value|g" "$output"
    done < <(awk '{ print length, $0 }' "$tokens" | sort -rn | cut -d' ' -f2-)
  done
}

token_value() {
  local file=$1 token=$2
  sed -n "s/^\$$token:[[:space:]]*\([^;]*\);/\1/p" "$file"
}

render_wallpaper() {
  local tokens=$1 stem=$2
  local bg surface border text brand_start brand_end watermark_opacity
  bg=$(token_value "$tokens" ent-bg)
  surface=$(token_value "$tokens" ent-surface)
  border=$(token_value "$tokens" ent-border)
  text=$(token_value "$tokens" ent-text)
  brand_start=$(token_value "$tokens" ent-brand-start)
  brand_end=$(token_value "$tokens" ent-brand-end)
  watermark_opacity=$(token_value "$tokens" ent-watermark-opacity)
  sed -e "s/@ENT_BG@/$bg/g" -e "s/@ENT_SURFACE@/$surface/g" \
      -e "s/@ENT_BORDER@/$border/g" -e "s/@ENT_TEXT@/$text/g" \
      -e "s/@ENT_BRAND_START@/$brand_start/g" -e "s/@ENT_BRAND_END@/$brand_end/g" \
      -e "s/@ENT_WATERMARK_OPACITY@/$watermark_opacity/g" \
      "$root/src/wallpaper/enterprise.svg" > "$dist/backgrounds/$stem.svg"
  magick -background none "$dist/backgrounds/$stem.svg" -resize 3840x2160! \
    -strip -define png:color-type=2 "$dist/backgrounds/$stem.png"
  magick "$dist/backgrounds/$stem.png" -quality 92 "$dist/backgrounds/$stem.jxl"
}

rm -rf "$dist"
for variant in Lyra-Enterprise Lyra-Enterprise-Light; do
  mkdir -p "$dist/$variant/gnome-shell" "$dist/$variant/gtk-4.0" \
    "$dist/$variant/gtk-3.0"
done
mkdir -p "$dist/backgrounds" "$dist/gnome-background-properties"
mkdir -p "$dist/grub/Lyra-Enterprise"

compile_scss "$root/src/shell/_tokens-dark.scss" "$root/src/shell/gnome-shell.scss" \
  "$dist/Lyra-Enterprise/gnome-shell/gnome-shell.css"
compile_scss "$root/src/shell/_tokens-light.scss" "$root/src/shell/gnome-shell.scss" \
  "$dist/Lyra-Enterprise-Light/gnome-shell/gnome-shell.css"
cp "$root/src/gtk4/gtk-dark.css" "$dist/Lyra-Enterprise/gtk-4.0/gtk.css"
cp "$root/src/gtk4/gtk-light.css" "$dist/Lyra-Enterprise-Light/gtk-4.0/gtk.css"
"$root/scripts/build-gtk3.sh" "$dist"
"$root/scripts/build-kde.sh" "$dist"
"$root/scripts/build-xfce.sh" "$dist"

command -v magick >/dev/null 2>&1 || { echo 'error: ImageMagick is required' >&2; exit 1; }
render_wallpaper "$root/src/shell/_tokens-dark.scss" enterprise
render_wallpaper "$root/src/shell/_tokens-light.scss" enterprise-light
cp "$root/src/wallpaper/lyra-enterprise.xml" "$dist/gnome-background-properties/"

cp "$root/src/grub/theme.txt" "$dist/grub/Lyra-Enterprise/"
magick -background none "$root/src/grub/background.svg" -resize 1920x1080! \
  -strip -define png:color-type=2 "$dist/grub/Lyra-Enterprise/background.png"
# GRUB stretches the middle segment between the fixed left/right caps.
for part in c e n ne nw s se sw w; do
  magick -background none "$root/src/grub/select.svg" -resize 2x2! -strip \
    "$dist/grub/Lyra-Enterprise/select_${part}.png"
done

"$root/scripts/check-contrast.js"
printf 'Built Lyra Enterprise in %s\n' "$dist"
