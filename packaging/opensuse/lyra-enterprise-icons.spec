# Ver lyra-enterprise-theme.spec neste mesmo diretório para as notas gerais
# (por que esta cópia existe, separada de packaging/lyra-enterprise-icons.spec).
%{!?version: %define version 0.0.0}

Name:           lyra-enterprise-icons
Version:        %{version}
Release:        1%{?dist}
Summary:        Flat sapphire icon theme for Lyra Enterprise
License:        GPL-3.0-or-later
URL:            https://github.com/britors/Lyra-Theme
Source0:        lyra-theme-src.tar.gz
BuildArch:      noarch
Requires:       adwaita-icon-theme

%description
Enterprise icon theme for Lyra OS. It provides branded vector icons for common
places, devices and applications and inherits Adwaita for complete GNOME coverage.

%prep
%setup -q -c -n lyra-theme-src

%build
./scripts/build-icons.sh

%install
install -d %{buildroot}%{_datadir}/icons
cp -a dist/Lyra-Enterprise-Icons %{buildroot}%{_datadir}/icons/

%files
%license LICENSE
%{_datadir}/icons/Lyra-Enterprise-Icons/

%changelog
