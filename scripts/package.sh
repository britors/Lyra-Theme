#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
"$root/scripts/build.sh"
archive="$root/Lyra-Enterprise.tar.xz"
rm -f "$archive"
tar -C "$root/dist" -cJf "$archive" Lyra-Enterprise Lyra-Enterprise-Light backgrounds gnome-background-properties grub plymouth neofetch fastfetch
printf 'Created %s\n' "$archive"
