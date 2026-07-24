#!/usr/bin/env bash
set -Eeuo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
variant=dark
activate=1
uninstall=0
grub=1
plymouth=1

usage() {
  cat <<'EOF'
Lyra Enterprise local installer (builds from this checkout)

Usage: install-local.sh [--dark|--light] [--no-activate] [--no-grub]
                         [--no-plymouth] [--uninstall]

  --dark          Use dark Adwaita with Lyra Enterprise icons (default)
  --light         Use light Adwaita with Lyra Enterprise icons
  --no-activate   Install files without changing GNOME, GRUB or Plymouth
                   settings, or the neofetch config
  --no-grub       Skip installing and activating the GRUB theme entirely
  --no-plymouth   Skip installing and activating the Plymouth theme entirely
  --uninstall     Remove both themes and restore GNOME defaults
EOF
}

while (($#)); do
  case $1 in
    --dark) variant=dark ;;
    --light) variant=light ;;
    --no-activate) activate=0 ;;
    --no-grub) grub=0 ;;
    --no-plymouth) plymouth=0 ;;
    --uninstall) uninstall=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# openSUSE ships GRUB 2 as grub2, configured via /boot/grub2/grub.cfg.
rebuild_grub_config() {
  if command -v grub2-mkconfig >/dev/null 2>&1; then
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
  elif [[ -x /usr/sbin/grub2-mkconfig ]]; then
    sudo /usr/sbin/grub2-mkconfig -o /boot/grub2/grub.cfg
  else
    say 'grub2-mkconfig not found; regenerate grub.cfg manually'
  fi
}

command -v sudo >/dev/null 2>&1 || die 'sudo is required'
if ! sudo -n true 2>/dev/null; then
  say 'Administrator authentication is required'
  sudo -v </dev/tty
fi

if ((uninstall)); then
  say 'Removing Lyra Enterprise'
  sudo rm -rf /usr/share/themes/Lyra-Enterprise \
    /usr/share/themes/Lyra-Enterprise-Light \
    /usr/share/icons/Lyra-Enterprise-Icons \
    /usr/share/grub/themes/Lyra-Enterprise \
    /usr/share/plymouth/themes/Lyra-Enterprise \
    /usr/share/lyra-enterprise-theme
  sudo rm -f /usr/share/backgrounds/lyra/enterprise.png \
    /usr/share/backgrounds/lyra/enterprise-light.png \
    /usr/share/backgrounds/lyra/enterprise.jxl \
    /usr/share/backgrounds/lyra/enterprise-light.jxl \
    /usr/share/gnome-background-properties/lyra-enterprise.xml
  if ((activate)) && command -v gsettings >/dev/null 2>&1; then
    [[ $(readlink "$HOME/.config/gtk-4.0/gtk.css" 2>/dev/null || true) == /usr/share/themes/Lyra-Enterprise* ]] && rm -f "$HOME/.config/gtk-4.0/gtk.css"
    gsettings reset org.gnome.shell.extensions.user-theme name 2>/dev/null || true
    gsettings reset org.gnome.desktop.interface gtk-theme 2>/dev/null || true
    gsettings reset org.gnome.desktop.interface icon-theme 2>/dev/null || true
    gsettings reset org.gnome.desktop.interface color-scheme 2>/dev/null || true
  fi
  if ((activate)) && [[ -f /etc/default/grub ]] && \
      sudo grep -qx 'GRUB_THEME="/usr/share/grub/themes/Lyra-Enterprise/theme.txt"' /etc/default/grub; then
    sudo sed -i '\|^GRUB_THEME="/usr/share/grub/themes/Lyra-Enterprise/theme.txt"$|d' /etc/default/grub
    if [[ -s /etc/default/grub.lyra-theme-backup ]]; then
      sudo sh -c 'cat /etc/default/grub.lyra-theme-backup >> /etc/default/grub'
    fi
    sudo rm -f /etc/default/grub.lyra-theme-backup
    rebuild_grub_config
  fi
  if ((activate)) && command -v plymouth-set-default-theme >/dev/null 2>&1; then
    if [[ -s /etc/plymouth/lyra-theme-backup ]]; then
      sudo plymouth-set-default-theme -R "$(sudo cat /etc/plymouth/lyra-theme-backup)"
    else
      sudo plymouth-set-default-theme -R details
    fi
    sudo rm -f /etc/plymouth/lyra-theme-backup
  fi
  if ((activate)); then
    if [[ -f "$HOME/.config/neofetch/config.conf.lyra-theme-backup" ]]; then
      mv "$HOME/.config/neofetch/config.conf.lyra-theme-backup" \
        "$HOME/.config/neofetch/config.conf"
    else
      rm -f "$HOME/.config/neofetch/config.conf"
    fi
    if [[ -f "$HOME/.config/fastfetch/config.jsonc.lyra-theme-backup" ]]; then
      mv "$HOME/.config/fastfetch/config.jsonc.lyra-theme-backup" \
        "$HOME/.config/fastfetch/config.jsonc"
    else
      rm -f "$HOME/.config/fastfetch/config.jsonc"
    fi
  fi
  say 'Uninstall complete'
  exit 0
fi

command -v magick >/dev/null 2>&1 || die 'ImageMagick 7 (magick) is required'
command -v rsvg-convert >/dev/null 2>&1 || die 'rsvg-convert is required'

say 'Building theme, icons, wallpapers, GRUB theme and Plymouth theme'
"$root/scripts/build.sh"
"$root/scripts/build-icons.sh"

say 'Installing system files'
sudo install -d /usr/share/themes /usr/share/icons \
  /usr/share/backgrounds/lyra /usr/share/gnome-background-properties \
  /usr/share/lyra-enterprise-theme/fastfetch
sudo cp -a "$root/dist/Lyra-Enterprise" \
  "$root/dist/Lyra-Enterprise-Light" /usr/share/themes/
sudo cp -a "$root/dist/Lyra-Enterprise-Icons" /usr/share/icons/
sudo install -m 0644 "$root"/dist/backgrounds/*.{png,jxl} \
  /usr/share/backgrounds/lyra/
sudo install -m 0644 \
  "$root/dist/gnome-background-properties/lyra-enterprise.xml" \
  /usr/share/gnome-background-properties/
sudo install -m 0644 "$root/dist/fastfetch/config.jsonc" \
  "$root/dist/fastfetch/logo.txt" \
  /usr/share/lyra-enterprise-theme/fastfetch/
if ((grub)); then
  sudo install -d /usr/share/grub/themes
  sudo cp -a "$root/dist/grub/Lyra-Enterprise" /usr/share/grub/themes/
fi
if ((plymouth)); then
  sudo install -d /usr/share/plymouth/themes
  sudo cp -a "$root/dist/plymouth/Lyra-Enterprise" /usr/share/plymouth/themes/
fi
command -v gtk-update-icon-cache >/dev/null 2>&1 && \
  sudo gtk-update-icon-cache -f /usr/share/icons/Lyra-Enterprise-Icons >/dev/null || true

if ((activate)); then
  say 'Installing Lyra neofetch config'
  mkdir -p "$HOME/.config/neofetch"
  if [[ -f "$HOME/.config/neofetch/config.conf" && \
      ! -f "$HOME/.config/neofetch/config.conf.lyra-theme-backup" ]]; then
    cp "$HOME/.config/neofetch/config.conf" \
      "$HOME/.config/neofetch/config.conf.lyra-theme-backup"
  fi
  cp "$root/dist/neofetch/config.conf" "$HOME/.config/neofetch/config.conf"

  say 'Installing Lyra Fastfetch config'
  mkdir -p "$HOME/.config/fastfetch"
  if [[ -f "$HOME/.config/fastfetch/config.jsonc" && \
      ! -f "$HOME/.config/fastfetch/config.jsonc.lyra-theme-backup" ]]; then
    cp "$HOME/.config/fastfetch/config.jsonc" \
      "$HOME/.config/fastfetch/config.jsonc.lyra-theme-backup"
  fi
  cp "$root/dist/fastfetch/config.jsonc" \
    "$HOME/.config/fastfetch/config.jsonc"
fi

if ((activate)) && command -v gsettings >/dev/null 2>&1; then
  if [[ $variant == light ]]; then
    scheme=prefer-light
  else
    scheme=prefer-dark
  fi
  say 'Activating Adwaita with Lyra Enterprise icons'
  gsettings reset org.gnome.shell.extensions.user-theme name 2>/dev/null || true
  gsettings reset org.gnome.desktop.interface gtk-theme 2>/dev/null || true
  gsettings set org.gnome.desktop.interface icon-theme 'Lyra-Enterprise-Icons'
  gsettings set org.gnome.desktop.interface accent-color 'blue' 2>/dev/null || true
  gsettings set org.gnome.desktop.interface color-scheme "$scheme"
  gsettings set org.gnome.desktop.background picture-uri \
    'file:///usr/share/backgrounds/lyra/enterprise-light.png'
  gsettings set org.gnome.desktop.background picture-uri-dark \
    'file:///usr/share/backgrounds/lyra/enterprise.png'
  if [[ $(readlink "$HOME/.config/gtk-4.0/gtk.css" 2>/dev/null || true) == /usr/share/themes/Lyra-Enterprise* ]]; then
    rm -f "$HOME/.config/gtk-4.0/gtk.css"
  fi
fi

if ((activate)) && ((grub)); then
  if [[ -f /etc/default/grub ]]; then
    say 'Activating Lyra Enterprise for GRUB'
    if ! sudo grep -qx 'GRUB_THEME="/usr/share/grub/themes/Lyra-Enterprise/theme.txt"' /etc/default/grub; then
      sudo sh -c "grep '^[[:space:]]*GRUB_THEME=' /etc/default/grub > /etc/default/grub.lyra-theme-backup || true"
    fi
    sudo sed -i '/^[[:space:]]*GRUB_THEME=/d' /etc/default/grub
    printf '%s\n' 'GRUB_THEME="/usr/share/grub/themes/Lyra-Enterprise/theme.txt"' | \
      sudo tee -a /etc/default/grub >/dev/null
    rebuild_grub_config
  else
    say '/etc/default/grub not found; GRUB theme was installed but not activated'
  fi
fi

if ((activate)) && ((plymouth)); then
  if command -v plymouth-set-default-theme >/dev/null 2>&1; then
    say 'Activating Lyra Enterprise for Plymouth'
    if [[ ! -s /etc/plymouth/lyra-theme-backup ]]; then
      plymouth-set-default-theme 2>/dev/null | sudo tee /etc/plymouth/lyra-theme-backup >/dev/null || true
    fi
    sudo plymouth-set-default-theme -R Lyra-Enterprise
  else
    say 'plymouth-set-default-theme not found; Plymouth theme was installed but not activated'
  fi
fi

say 'Lyra Enterprise installation complete'
printf 'Adwaita remains active for GNOME Shell and applications; Lyra supplies the icons.\n'
