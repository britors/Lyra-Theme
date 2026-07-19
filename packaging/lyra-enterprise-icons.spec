Name:           lyra-enterprise-icons
Version:        1.1.0
Release:        1%{?dist}
Summary:        Flat sapphire icon theme for Lyra Enterprise
License:        GPL-3.0-or-later
URL:            https://github.com/britors/lyra-enterprise-theme
Source0:        lyra-enterprise-theme-%{version}.tar.xz
BuildArch:      noarch
Requires:       adwaita-icon-theme

%description
Enterprise icon theme for Lyra OS. It provides branded vector icons for common
places, devices and applications and inherits Adwaita for complete GNOME coverage.

%prep
%autosetup -n lyra-enterprise-theme-%{version}

%build
./scripts/build-icons.sh

%install
install -d %{buildroot}%{_datadir}/icons
cp -a dist/Lyra-Enterprise-Icons %{buildroot}%{_datadir}/icons/

%files
%license LICENSE
%{_datadir}/icons/Lyra-Enterprise-Icons/

%changelog
* Sun Jul 19 2026 Lyra OS Team <contact@lyraos.dev> - 1.1.0-1
- Release icons for Lyra Enterprise 1.1.0

* Sun Jul 19 2026 Lyra OS Team <contact@lyraos.dev> - 1.0.0-1
- Initial enterprise icon theme
