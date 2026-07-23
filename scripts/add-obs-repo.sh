#!/usr/bin/env bash
set -Eeuo pipefail

repo_alias='home_rodrigosbrito_lyra'
repo_url='https://download.opensuse.org/repositories/home:/rodrigosbrito:/lyra/openSUSE_Leap_16.0/home:rodrigosbrito:lyra.repo'
install=1

usage() {
  cat <<'EOF'
Add the openSUSE Build Service repo for Lyra packages (home:rodrigosbrito:lyra)
and, by default, install the theme and icon RPMs from it.

Usage: add-obs-repo.sh [--no-install]

  --no-install    Only add and refresh the repo; skip installing the packages
EOF
}

while (($#)); do
  case $1 in
    --no-install) install=0 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

command -v zypper >/dev/null 2>&1 || die 'zypper is required (openSUSE only)'
command -v sudo >/dev/null 2>&1 || die 'sudo is required'

say "Adding repo $repo_alias"
if sudo zypper lr "$repo_alias" >/dev/null 2>&1; then
  say 'Repo already added, refreshing instead'
else
  sudo zypper --non-interactive ar --refresh "$repo_url" "$repo_alias"
fi

say 'Refreshing and importing the repo GPG key'
sudo zypper --gpg-auto-import-keys refresh "$repo_alias"

if ((install)); then
  say 'Installing lyra-enterprise-theme and lyra-enterprise-icons'
  sudo zypper --non-interactive install lyra-enterprise-theme lyra-enterprise-icons
fi

say 'Done'
