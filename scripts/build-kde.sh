#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
dist=${1:-"$root/dist"}

token_value() {
  local file=$1 token=$2
  sed -n "s/^\$$token:[[:space:]]*\([^;]*\);/\1/p" "$file"
}

hex_to_rgb() {
  local hex=${1#\#}
  printf '%d,%d,%d' "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

render_plasma() {
  local tokens=$1 output=$2 scheme_id=$3 scheme_name=$4
  local bg surface raised border text_dim text accent accent_hover success warning danger brand_end
  bg=$(hex_to_rgb "$(token_value "$tokens" ent-bg)")
  surface=$(hex_to_rgb "$(token_value "$tokens" ent-surface)")
  raised=$(hex_to_rgb "$(token_value "$tokens" ent-surface-raised)")
  border=$(hex_to_rgb "$(token_value "$tokens" ent-border)")
  text_dim=$(hex_to_rgb "$(token_value "$tokens" ent-text-dim)")
  text=$(hex_to_rgb "$(token_value "$tokens" ent-text)")
  accent=$(hex_to_rgb "$(token_value "$tokens" ent-accent)")
  accent_hover=$(hex_to_rgb "$(token_value "$tokens" ent-accent-hover)")
  success=$(hex_to_rgb "$(token_value "$tokens" ent-success)")
  warning=$(hex_to_rgb "$(token_value "$tokens" ent-warning)")
  danger=$(hex_to_rgb "$(token_value "$tokens" ent-danger)")
  brand_end=$(hex_to_rgb "$(token_value "$tokens" ent-brand-end)")

  sed -e "s/@ENT_BG@/$bg/g" -e "s/@ENT_SURFACE_RAISED@/$raised/g" \
      -e "s/@ENT_SURFACE@/$surface/g" -e "s/@ENT_BORDER@/$border/g" \
      -e "s/@ENT_TEXT_DIM@/$text_dim/g" -e "s/@ENT_TEXT@/$text/g" \
      -e "s/@ENT_ACCENT_HOVER@/$accent_hover/g" -e "s/@ENT_ACCENT@/$accent/g" \
      -e "s/@ENT_SUCCESS@/$success/g" -e "s/@ENT_WARNING@/$warning/g" \
      -e "s/@ENT_DANGER@/$danger/g" -e "s/@ENT_BRAND_END@/$brand_end/g" \
      -e "s/@ENT_SCHEME_ID@/$scheme_id/g" -e "s/@ENT_SCHEME_NAME@/$scheme_name/g" \
      "$root/src/kde/lyra-enterprise.colors.tmpl" > "$output"
}

# Bright ANSI accents that have no direct token equivalent; designed to read
# well as bold/intense terminal colors against each variant's base palette.
render_konsole() {
  local variant=$1 tokens=$2 output=$3 label=$4
  local surface raised border text_dim text accent_hover success warning danger brand_start brand_end
  surface=$(hex_to_rgb "$(token_value "$tokens" ent-surface)")
  raised=$(hex_to_rgb "$(token_value "$tokens" ent-surface-raised)")
  border=$(hex_to_rgb "$(token_value "$tokens" ent-border)")
  text_dim=$(hex_to_rgb "$(token_value "$tokens" ent-text-dim)")
  text=$(hex_to_rgb "$(token_value "$tokens" ent-text)")
  accent_hover=$(hex_to_rgb "$(token_value "$tokens" ent-accent-hover)")
  success=$(hex_to_rgb "$(token_value "$tokens" ent-success)")
  warning=$(hex_to_rgb "$(token_value "$tokens" ent-warning)")
  danger=$(hex_to_rgb "$(token_value "$tokens" ent-danger)")
  brand_start=$(hex_to_rgb "$(token_value "$tokens" ent-brand-start)")
  brand_end=$(hex_to_rgb "$(token_value "$tokens" ent-brand-end)")
  local bg fg="$text"
  bg=$(hex_to_rgb "$(token_value "$tokens" ent-bg)")

  local c0 c7 c0i c7i c1i c2i c3i c6i c5i fgi
  if [[ $variant == dark ]]; then
    c0=$surface; c7=$text_dim
    c0i=$border; c7i=$text
    c1i=226,87,79 c2i=52,199,117 c3i=217,154,61 c6i=109,219,254 c5i=209,122,253
    fgi=255,255,255
  else
    c0=$text; c7=$border
    c0i=$text_dim; c7i=255,255,255
    c1i=197,48,48 c2i=31,157,85 c3i=183,121,31 c6i=42,199,253 c5i=190,73,253
    fgi=0,0,0
  fi

  sed -e "s/@ENT_BG_FAINT@/$surface/g" -e "s/@ENT_BG_INTENSE@/$raised/g" \
      -e "s/@ENT_BG@/$bg/g" \
      -e "s/@ENT_C0I@/$c0i/g" -e "s/@ENT_C0@/$c0/g" \
      -e "s/@ENT_C1I@/$c1i/g" -e "s/@ENT_C1@/$danger/g" \
      -e "s/@ENT_C2I@/$c2i/g" -e "s/@ENT_C2@/$success/g" \
      -e "s/@ENT_C3I@/$c3i/g" -e "s/@ENT_C3@/$warning/g" \
      -e "s/@ENT_C4I@/$accent_hover/g" -e "s/@ENT_C4@/$(hex_to_rgb "$(token_value "$tokens" ent-accent)")/g" \
      -e "s/@ENT_C5I@/$c5i/g" -e "s/@ENT_C5@/$brand_end/g" \
      -e "s/@ENT_C6I@/$c6i/g" -e "s/@ENT_C6@/$brand_start/g" \
      -e "s/@ENT_C7I@/$c7i/g" -e "s/@ENT_C7@/$c7/g" \
      -e "s/@ENT_FG_FAINT@/$text_dim/g" -e "s/@ENT_FGI@/$fgi/g" -e "s/@ENT_FG@/$fg/g" \
      -e "s/@ENT_LABEL@/$label/g" \
      "$root/src/kde/lyra-enterprise.colorscheme.tmpl" > "$output"
}

mkdir -p "$dist/kde/color-schemes" "$dist/kde/konsole"

render_plasma "$root/src/shell/_tokens-dark.scss" \
  "$dist/kde/color-schemes/Lyra-Enterprise.colors" \
  Lyra-Enterprise 'Lyra Enterprise'
render_plasma "$root/src/shell/_tokens-light.scss" \
  "$dist/kde/color-schemes/Lyra-Enterprise-Light.colors" \
  Lyra-Enterprise-Light 'Lyra Enterprise Light'

render_konsole dark "$root/src/shell/_tokens-dark.scss" \
  "$dist/kde/konsole/Lyra-Enterprise.colorscheme" 'Lyra Enterprise'
render_konsole light "$root/src/shell/_tokens-light.scss" \
  "$dist/kde/konsole/Lyra-Enterprise-Light.colorscheme" 'Lyra Enterprise Light'
