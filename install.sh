#!/usr/bin/env bash
set -Eeuo pipefail

repo=${LYRA_REPO:-britors/Lyra-Theme}
ref=${LYRA_REF:-main}
variant=dark
activate=1
uninstall=0
grub=1

usage() {
  cat <<'EOF'
Lyra Enterprise installer

Usage: install.sh [--dark|--light] [--no-activate] [--no-grub] [--uninstall]

  --dark          Use dark Adwaita with Lyra Enterprise icons (default)
  --light         Use light Adwaita with Lyra Enterprise icons
  --no-activate   Install files without changing GNOME or GRUB settings
  --no-grub       Skip installing and activating the GRUB theme entirely
  --uninstall     Remove both themes and restore GNOME defaults
EOF
}

while (($#)); do
  case $1 in
    --dark) variant=dark ;;
    --light) variant=light ;;
    --no-activate) activate=0 ;;
    --no-grub) grub=0 ;;
    --uninstall) uninstall=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

rebuild_grub_config() {
  local update_grub grub_mkconfig
  update_grub=$(command -v update-grub 2>/dev/null || true)
  grub_mkconfig=$(command -v grub2-mkconfig 2>/dev/null || \
    command -v grub-mkconfig 2>/dev/null || true)
  [[ -n $update_grub ]] || [[ ! -x /usr/sbin/update-grub ]] || \
    update_grub=/usr/sbin/update-grub
  if [[ -z $grub_mkconfig ]]; then
    if [[ -x /usr/sbin/grub2-mkconfig ]]; then
      grub_mkconfig=/usr/sbin/grub2-mkconfig
    elif [[ -x /usr/sbin/grub-mkconfig ]]; then
      grub_mkconfig=/usr/sbin/grub-mkconfig
    fi
  fi

  if [[ -n $update_grub ]]; then
    sudo "$update_grub"
  elif [[ -n $grub_mkconfig ]]; then
    if [[ -d /boot/grub2 ]]; then
      sudo "$grub_mkconfig" -o /boot/grub2/grub.cfg
    else
      sudo "$grub_mkconfig" -o /boot/grub/grub.cfg
    fi
  else
    say 'GRUB configuration tool not found; regenerate grub.cfg manually'
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
    /usr/share/grub/themes/Lyra-Enterprise
  sudo rm -f /usr/share/backgrounds/lyra/enterprise.png \
    /usr/share/backgrounds/lyra/enterprise-light.png \
    /usr/share/backgrounds/lyra/enterprise.jxl \
    /usr/share/backgrounds/lyra/enterprise-light.jxl \
    /usr/share/gnome-background-properties/lyra-enterprise.xml \
    /usr/share/color-schemes/Lyra-Enterprise.colors \
    /usr/share/color-schemes/Lyra-Enterprise-Light.colors \
    /usr/share/konsole/Lyra-Enterprise.colorscheme \
    /usr/share/konsole/Lyra-Enterprise-Light.colorscheme
  if ((activate)) && command -v gsettings >/dev/null 2>&1; then
    [[ $(readlink "$HOME/.config/gtk-4.0/gtk.css" 2>/dev/null || true) == /usr/share/themes/Lyra-Enterprise* ]] && rm -f "$HOME/.config/gtk-4.0/gtk.css"
    gsettings reset org.gnome.shell.extensions.user-theme name 2>/dev/null || true
    gsettings reset org.gnome.desktop.interface gtk-theme 2>/dev/null || true
    gsettings reset org.gnome.desktop.interface icon-theme 2>/dev/null || true
    gsettings reset org.gnome.desktop.interface color-scheme 2>/dev/null || true
  fi
  if ((activate)) && command -v plasma-apply-colorscheme >/dev/null 2>&1 && \
      [[ ${XDG_CURRENT_DESKTOP:-} == *KDE* ]]; then
    plasma-apply-colorscheme BreezeDark >/dev/null 2>&1 || true
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
  say 'Uninstall complete'
  exit 0
fi

install_dependencies() {
  say 'Installing build and runtime dependencies'
  if command -v zypper >/dev/null 2>&1; then
    sudo zypper --non-interactive install \
      curl tar xz ImageMagick nodejs sassc
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm \
      curl tar xz imagemagick nodejs sassc
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y \
      curl tar xz ImageMagick nodejs sassc
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y curl tar xz-utils imagemagick nodejs sassc
  else
    die 'Unsupported distribution. Install curl, tar, xz, ImageMagick, nodejs and sassc manually.'
  fi
}

install_dependencies
command -v curl >/dev/null 2>&1 || die 'curl was not installed'
command -v magick >/dev/null 2>&1 || die 'ImageMagick 7 (magick) is required'

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
archive="$tmp/source.tar.gz"
source_dir="$tmp/source"
mkdir -p "$source_dir"

say "Downloading $repo ($ref)"
curl --proto '=https' --tlsv1.2 -fsSL \
  "https://github.com/$repo/archive/$ref.tar.gz" -o "$archive"
tar -xzf "$archive" -C "$source_dir" --strip-components=1

say 'Building themes, icons, wallpapers and GRUB theme'
(cd "$source_dir" && ./scripts/build.sh && ./scripts/build-icons.sh)

say 'Installing system files'
sudo install -d /usr/share/themes /usr/share/icons \
  /usr/share/backgrounds/lyra /usr/share/gnome-background-properties \
  /usr/share/color-schemes /usr/share/konsole
sudo cp -a "$source_dir/dist/Lyra-Enterprise" \
  "$source_dir/dist/Lyra-Enterprise-Light" /usr/share/themes/
sudo cp -a "$source_dir/dist/Lyra-Enterprise-Icons" /usr/share/icons/
sudo install -m 0644 "$source_dir"/dist/backgrounds/*.{png,jxl} \
  /usr/share/backgrounds/lyra/
sudo install -m 0644 \
  "$source_dir/dist/gnome-background-properties/lyra-enterprise.xml" \
  /usr/share/gnome-background-properties/
sudo install -m 0644 "$source_dir"/dist/kde/color-schemes/*.colors \
  /usr/share/color-schemes/
sudo install -m 0644 "$source_dir"/dist/kde/konsole/*.colorscheme \
  /usr/share/konsole/
if ((grub)); then
  sudo install -d /usr/share/grub/themes
  sudo cp -a "$source_dir/dist/grub/Lyra-Enterprise" /usr/share/grub/themes/
fi
command -v gtk-update-icon-cache >/dev/null 2>&1 && \
  sudo gtk-update-icon-cache -f /usr/share/icons/Lyra-Enterprise-Icons >/dev/null || true

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

if ((activate)) && command -v plasma-apply-colorscheme >/dev/null 2>&1 && \
    [[ ${XDG_CURRENT_DESKTOP:-} == *KDE* ]]; then
  say 'Activating Lyra Enterprise Plasma color scheme'
  if [[ $variant == light ]]; then
    plasma-apply-colorscheme Lyra-Enterprise-Light
  else
    plasma-apply-colorscheme Lyra-Enterprise
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

say 'Lyra Enterprise installation complete'
printf 'Adwaita remains active for GNOME Shell and applications; Lyra supplies the icons.\n'
