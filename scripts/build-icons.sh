#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
out="$root/dist/Lyra-Enterprise-Icons"
rm -rf "$out"
mkdir -p "$out/scalable"
cp "$root/src/icons/index.theme" "$out/"
cp -a "$root/src/icons/scalable/." "$out/scalable/"

link_icon() {
  local dir=$1 target=$2; shift 2
  for alias in "$@"; do ln -s "$target.svg" "$out/scalable/$dir/$alias.svg"; done
}

link_icon places folder folder-documents folder-download folder-music folder-pictures folder-publicshare folder-templates folder-videos
link_icon places user-home user-home-symbolic
link_icon devices computer computer-symbolic video-display
link_icon devices drive-harddisk drive-harddisk-symbolic drive-removable-media
link_icon apps applications-system applications-other system-software-install
link_icon apps org.gnome.Settings preferences-system org.gnome.Settings.Devel
link_icon apps utilities-terminal org.gnome.Console org.gnome.Terminal
link_icon status user-trash user-trash-full
printf 'Built Lyra Enterprise Icons in %s\n' "$out"

