#!/usr/bin/env bash
set -Eeuo pipefail

repo_alias='home_rodrigosbrito_lyra'
repo_url='https://download.opensuse.org/repositories/home:/rodrigosbrito:/lyra/openSUSE_Leap_16.0/'
variant=dark

usage() {
  cat <<'EOF'
Lyra Enterprise RPM installer

Usage: install-rpm.sh [--dark|--light]

  --dark     Activate the dark wallpaper and color scheme (default)
  --light    Activate the light wallpaper and color scheme
EOF
}

while (($#)); do
  case $1 in
    --dark) variant=dark ;;
    --light) variant=light ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

command -v zypper >/dev/null 2>&1 || die 'This installer supports openSUSE (zypper) only.'
command -v sudo >/dev/null 2>&1 || die 'sudo is required'

if ! sudo -n true 2>/dev/null; then
  say 'Administrator authentication is required'
  sudo -v </dev/tty
fi

say "Configuring the Lyra package repository"
if sudo zypper lr "$repo_alias" >/dev/null 2>&1; then
  sudo zypper --non-interactive rr "$repo_alias"
fi
sudo zypper --non-interactive ar --refresh "$repo_url" "$repo_alias"
sudo zypper --gpg-auto-import-keys refresh "$repo_alias"

say 'Installing the Lyra theme and icon packages'
sudo zypper --non-interactive install \
  lyra-enterprise-theme lyra-enterprise-icons

if command -v gsettings >/dev/null 2>&1; then
  say 'Activating Lyra icons and wallpapers'
  gsettings set org.gnome.desktop.interface icon-theme 'Lyra-Enterprise-Icons'
  gsettings set org.gnome.desktop.interface accent-color 'blue' 2>/dev/null || true

  if [[ $variant == light ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
  else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  fi

  gsettings set org.gnome.desktop.background picture-uri \
    'file:///usr/share/backgrounds/lyra/enterprise-light.png'
  gsettings set org.gnome.desktop.background picture-uri-dark \
    'file:///usr/share/backgrounds/lyra/enterprise.png'
else
  say 'gsettings not found; GNOME will use the packaged defaults on a new profile'
fi

if [[ -f /usr/share/lyra-enterprise-theme/neofetch/config.conf ]]; then
  say 'Activating the Lyra Neofetch configuration'
  mkdir -p "$HOME/.config/neofetch"
  if [[ -f "$HOME/.config/neofetch/config.conf" && \
      ! -f "$HOME/.config/neofetch/config.conf.lyra-theme-backup" ]]; then
    cp "$HOME/.config/neofetch/config.conf" \
      "$HOME/.config/neofetch/config.conf.lyra-theme-backup"
  fi
  cp /usr/share/lyra-enterprise-theme/neofetch/config.conf \
    "$HOME/.config/neofetch/config.conf"
fi

if [[ -f /etc/default/grub ]]; then
  say 'Confirming the Lyra GRUB theme'
  sudo sed -i '/^[[:space:]]*GRUB_THEME=/d' /etc/default/grub
  printf '%s\n' \
    'GRUB_THEME="/usr/share/grub/themes/Lyra-Enterprise/theme.txt"' |
    sudo tee -a /etc/default/grub >/dev/null
  sudo grub2-mkconfig -o /boot/grub2/grub.cfg
fi

if command -v plymouth-set-default-theme >/dev/null 2>&1; then
  say 'Confirming the Lyra Plymouth theme'
  sudo plymouth-set-default-theme -R Lyra-Enterprise
fi

say 'Lyra Enterprise is installed and active'
