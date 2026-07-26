# Ver lyra-os-theme.spec neste mesmo diretório para as notas gerais
# (por que esta cópia existe, separada de packaging/lyra-os-icons.spec).
%{!?version: %define version 0.0.0}

Name:           lyra-os-icons
Version:        %{version}
Release:        1%{?dist}
Summary:        Flat sapphire icon theme for Lyra OS
License:        GPL-3.0-or-later
URL:            https://github.com/britors/Lyra-Theme
Source0:        lyra-theme-src.tar.gz
BuildArch:      noarch
Requires:       adwaita-icon-theme

%description
Icon theme for Lyra OS. It provides branded vector icons for common
places, devices and applications and inherits Adwaita for complete GNOME coverage.

%prep
%setup -q -c -n lyra-theme-src

%build
./scripts/build-icons.sh

%install
install -d %{buildroot}%{_datadir}/icons
cp -a dist/Lyra-OS-Icons %{buildroot}%{_datadir}/icons/

%files
%license LICENSE
%{_datadir}/icons/Lyra-OS-Icons/

%changelog
