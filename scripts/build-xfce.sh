#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
dist=${1:-"$root/dist"}

token_value() {
  local file=$1 token=$2
  sed -n "s/^\$$token:[[:space:]]*\([^;]*\);/\1/p" "$file"
}

render_xfwm4() {
  local tokens=$1 output=$2
  local surface_raised surface text_dim text
  surface_raised=$(token_value "$tokens" ent-surface-raised)
  surface=$(token_value "$tokens" ent-surface)
  text_dim=$(token_value "$tokens" ent-text-dim)
  text=$(token_value "$tokens" ent-text)

  sed -e "s/@ENT_SURFACE_RAISED@/$surface_raised/g" -e "s/@ENT_SURFACE@/$surface/g" \
      -e "s/@ENT_TEXT_DIM@/$text_dim/g" -e "s/@ENT_TEXT@/$text/g" \
      "$root/src/xfwm4/themerc.tmpl" > "$output"
}

# Bright ANSI accents that have no direct token equivalent; designed to read
# well as bold/intense terminal colors against each variant's base palette.
# Same assignment used for the Konsole scheme in scripts/build-kde.sh.
render_terminal() {
  local variant=$1 tokens=$2 output=$3 label=$4
  local surface border text_dim text accent accent_hover success warning danger brand_start brand_end bg
  surface=$(token_value "$tokens" ent-surface)
  border=$(token_value "$tokens" ent-border)
  text_dim=$(token_value "$tokens" ent-text-dim)
  text=$(token_value "$tokens" ent-text)
  accent=$(token_value "$tokens" ent-accent)
  accent_hover=$(token_value "$tokens" ent-accent-hover)
  success=$(token_value "$tokens" ent-success)
  warning=$(token_value "$tokens" ent-warning)
  danger=$(token_value "$tokens" ent-danger)
  brand_start=$(token_value "$tokens" ent-brand-start)
  brand_end=$(token_value "$tokens" ent-brand-end)
  bg=$(token_value "$tokens" ent-bg)

  local c0 c7 c0i c7i c1i c2i c3i c6i c5i
  if [[ $variant == dark ]]; then
    c0=$surface; c7=$text_dim
    c0i=$border; c7i=$text
    c1i=#E2574F c2i=#34C775 c3i=#D99A3D c6i=#6DDBFE c5i=#D17AFD
  else
    c0=$text; c7=$border
    c0i=$text_dim; c7i=#FFFFFF
    c1i=#C53030 c2i=#1F9D55 c3i=#B7791F c6i=#2AC7FD c5i=#BE49FD
  fi

  sed -e "s/@ENT_C0@/$c0/g" -e "s/@ENT_C1@/$danger/g" -e "s/@ENT_C2@/$success/g" \
      -e "s/@ENT_C3@/$warning/g" -e "s/@ENT_C4@/$accent/g" -e "s/@ENT_C5@/$brand_end/g" \
      -e "s/@ENT_C6@/$brand_start/g" -e "s/@ENT_C7@/$c7/g" \
      -e "s/@ENT_C0I@/$c0i/g" -e "s/@ENT_C1I@/$c1i/g" -e "s/@ENT_C2I@/$c2i/g" \
      -e "s/@ENT_C3I@/$c3i/g" -e "s/@ENT_C4I@/$accent_hover/g" -e "s/@ENT_C5I@/$c5i/g" \
      -e "s/@ENT_C6I@/$c6i/g" -e "s/@ENT_C7I@/$c7i/g" \
      -e "s/@ENT_FG@/$text/g" -e "s/@ENT_BG@/$bg/g" -e "s/@ENT_LABEL@/$label/g" \
      "$root/src/xfce4-terminal/lyra-enterprise.theme.tmpl" > "$output"
}

mkdir -p "$dist/Lyra-Enterprise/xfwm4" "$dist/Lyra-Enterprise-Light/xfwm4"
mkdir -p "$dist/xfce4-terminal/colorschemes"

render_xfwm4 "$root/src/shell/_tokens-dark.scss" \
  "$dist/Lyra-Enterprise/xfwm4/themerc"
render_xfwm4 "$root/src/shell/_tokens-light.scss" \
  "$dist/Lyra-Enterprise-Light/xfwm4/themerc"

render_terminal dark "$root/src/shell/_tokens-dark.scss" \
  "$dist/xfce4-terminal/colorschemes/Lyra-Enterprise.theme" 'Lyra Enterprise'
render_terminal light "$root/src/shell/_tokens-light.scss" \
  "$dist/xfce4-terminal/colorschemes/Lyra-Enterprise-Light.theme" 'Lyra Enterprise Light'
