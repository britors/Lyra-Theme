#!/usr/bin/env bash
set -Eeuo pipefail

repo=${LYRA_REPO:-britors/Lyra-Theme}
ref=${LYRA_REF:-main}
variant=dark
activate=1
uninstall=0

usage() {
  cat <<'EOF'
Lyra Enterprise installer

Usage: install.sh [--dark|--light] [--no-activate] [--uninstall]

  --dark          Install and activate Lyra-Enterprise (default)
  --light         Install and activate Lyra-Enterprise-Light
  --no-activate   Install files without changing GNOME preferences
  --uninstall     Remove both themes and restore GNOME defaults
EOF
}

while (($#)); do
  case $1 in
    --dark) variant=dark ;;
    --light) variant=light ;;
    --no-activate) activate=0 ;;
    --uninstall) uninstall=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

command -v sudo >/dev/null 2>&1 || die 'sudo is required'
if ! sudo -n true 2>/dev/null; then
  say 'Administrator authentication is required'
  sudo -v </dev/tty
fi

if ((uninstall)); then
  say 'Removing Lyra Enterprise'
  sudo rm -rf /usr/share/themes/Lyra-Enterprise \
    /usr/share/themes/Lyra-Enterprise-Light \
    /usr/share/icons/Lyra-Enterprise-Icons
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
  say 'Uninstall complete'
  exit 0
fi

install_dependencies() {
  say 'Installing build and runtime dependencies'
  if command -v zypper >/dev/null 2>&1; then
    sudo zypper --non-interactive install \
      curl tar xz ImageMagick nodejs sassc gnome-shell-extension-user-theme
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm \
      curl tar xz imagemagick nodejs sassc gnome-shell-extension-user-theme
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y \
      curl tar xz ImageMagick nodejs sassc gnome-shell-extension-user-theme
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y curl tar xz-utils imagemagick nodejs sassc \
      gnome-shell-extension-user-theme
  else
    die 'Unsupported distribution. Install curl, tar, xz, ImageMagick, nodejs, sassc and User Themes manually.'
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

say 'Building themes, icons and wallpapers'
(cd "$source_dir" && ./scripts/build.sh && ./scripts/build-icons.sh)

say 'Installing system files'
sudo install -d /usr/share/themes /usr/share/icons \
  /usr/share/backgrounds/lyra /usr/share/gnome-background-properties
sudo cp -a "$source_dir/dist/Lyra-Enterprise" \
  "$source_dir/dist/Lyra-Enterprise-Light" /usr/share/themes/
sudo cp -a "$source_dir/dist/Lyra-Enterprise-Icons" /usr/share/icons/
sudo install -m 0644 "$source_dir"/dist/backgrounds/*.{png,jxl} \
  /usr/share/backgrounds/lyra/
sudo install -m 0644 \
  "$source_dir/dist/gnome-background-properties/lyra-enterprise.xml" \
  /usr/share/gnome-background-properties/
command -v gtk-update-icon-cache >/dev/null 2>&1 && \
  sudo gtk-update-icon-cache -f /usr/share/icons/Lyra-Enterprise-Icons >/dev/null || true

if ((activate)) && command -v gsettings >/dev/null 2>&1; then
  if [[ $variant == light ]]; then
    theme=Lyra-Enterprise-Light
    scheme=prefer-light
  else
    theme=Lyra-Enterprise
    scheme=prefer-dark
  fi
  say "Activating $theme"
  gsettings set org.gnome.shell.extensions.user-theme name "$theme"
  gsettings set org.gnome.desktop.interface gtk-theme "$theme"
  gsettings set org.gnome.desktop.interface icon-theme 'Lyra-Enterprise-Icons'
  gsettings set org.gnome.desktop.interface accent-color 'blue' 2>/dev/null || true
  gsettings set org.gnome.desktop.interface color-scheme "$scheme"
  gsettings set org.gnome.desktop.background picture-uri \
    'file:///usr/share/backgrounds/lyra/enterprise-light.png'
  gsettings set org.gnome.desktop.background picture-uri-dark \
    'file:///usr/share/backgrounds/lyra/enterprise.png'
  mkdir -p "$HOME/.config/gtk-4.0"
  ln -sfn "/usr/share/themes/$theme/gtk-4.0/gtk.css" \
    "$HOME/.config/gtk-4.0/gtk.css"
  uuid=user-theme@gnome-shell-extensions.gcampax.github.com
  if ! gnome-extensions enable "$uuid" 2>/dev/null; then
    current=$(gsettings get org.gnome.shell enabled-extensions)
    if [[ $current != *"'$uuid'"* ]]; then
      if [[ $current == '@as []' || $current == '[]' ]]; then
        updated="['$uuid']"
      else
        updated=$(printf '%s' "$current" | sed "s/]$/, '$uuid']/")
      fi
      gsettings set org.gnome.shell enabled-extensions "$updated"
    fi
  fi
fi

say 'Lyra Enterprise installation complete'
printf 'Log out and back in once so GNOME Shell can load a newly installed User Themes extension.\n'
