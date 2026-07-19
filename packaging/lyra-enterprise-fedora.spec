Name:           lyra-enterprise
Version:        1.0.0
Release:        1%{?dist}
Summary:        Corporate GNOME theme, icons and wallpapers for Lyra OS
License:        GPL-3.0-or-later AND LGPL-2.1-or-later
URL:            https://github.com/britors/Lyra-Theme
Source0:        %{url}/archive/v%{version}/Lyra-Theme-%{version}.tar.gz
BuildArch:      noarch

BuildRequires:  ImageMagick
BuildRequires:  nodejs
BuildRequires:  sassc
Requires:       adwaita-icon-theme
Requires:       gnome-shell-extension-user-theme

%description
Lyra Enterprise is a flat corporate theme for GNOME 48 and newer. This package
contains dark and light GNOME Shell, GTK 4 and GTK 3 themes, a scalable icon
theme inheriting Adwaita, and matching 4K wallpapers in PNG and JPEG XL.

%prep
%autosetup -n Lyra-Theme-%{version}

%build
./scripts/build.sh
./scripts/build-icons.sh

%install
install -d %{buildroot}%{_datadir}/themes
cp -a dist/Lyra-Enterprise dist/Lyra-Enterprise-Light \
  %{buildroot}%{_datadir}/themes/

install -d %{buildroot}%{_datadir}/icons
cp -a dist/Lyra-Enterprise-Icons %{buildroot}%{_datadir}/icons/

install -d %{buildroot}%{_datadir}/backgrounds/lyra
install -m 0644 dist/backgrounds/*.png dist/backgrounds/*.jxl \
  %{buildroot}%{_datadir}/backgrounds/lyra/

install -d %{buildroot}%{_datadir}/gnome-background-properties
install -m 0644 dist/gnome-background-properties/lyra-enterprise.xml \
  %{buildroot}%{_datadir}/gnome-background-properties/

%files
%license LICENSE src/gtk3/COPYING.LGPL
%doc README.md src/gtk3/ATTRIBUTION.md
%{_datadir}/themes/Lyra-Enterprise/
%{_datadir}/themes/Lyra-Enterprise-Light/
%{_datadir}/icons/Lyra-Enterprise-Icons/
%{_datadir}/backgrounds/lyra/enterprise.png
%{_datadir}/backgrounds/lyra/enterprise.jxl
%{_datadir}/backgrounds/lyra/enterprise-light.png
%{_datadir}/backgrounds/lyra/enterprise-light.jxl
%{_datadir}/gnome-background-properties/lyra-enterprise.xml

%changelog
* Sun Jul 19 2026 Lyra OS Team <contact@lyraos.dev> - 1.0.0-1
- Initial Fedora package with themes, icons and wallpapers

