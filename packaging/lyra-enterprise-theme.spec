Name:           lyra-enterprise-theme
Version:        1.1.0
Release:        1%{?dist}
Summary:        Corporate GNOME and GRUB theme for Lyra OS
License:        GPL-3.0-or-later AND LGPL-2.1-or-later
URL:            https://github.com/britors/lyra-enterprise-theme
Source0:        %{name}-%{version}.tar.xz
BuildArch:      noarch
BuildRequires:  ImageMagick
BuildRequires:  nodejs
BuildRequires:  sassc

%description
Corporate, flat GNOME 48+ theme with dark and light variants for GNOME Shell,
GTK 4/libadwaita and GTK 3. Includes matching PNG and JPEG XL wallpapers.
Also includes the Lyra Enterprise boot menu theme for GRUB 2.

%prep
%autosetup

%build
./scripts/build.sh

%install
install -d %{buildroot}%{_datadir}/themes
cp -a dist/Lyra-Enterprise dist/Lyra-Enterprise-Light %{buildroot}%{_datadir}/themes/

install -d %{buildroot}%{_datadir}/backgrounds/lyra
install -m 0644 dist/backgrounds/*.png dist/backgrounds/*.jxl \
  %{buildroot}%{_datadir}/backgrounds/lyra/

install -d %{buildroot}%{_datadir}/gnome-background-properties
install -m 0644 dist/gnome-background-properties/lyra-enterprise.xml \
  %{buildroot}%{_datadir}/gnome-background-properties/

install -d %{buildroot}%{_datadir}/grub/themes
cp -a dist/grub/Lyra-Enterprise %{buildroot}%{_datadir}/grub/themes/

%files
%license LICENSE src/gtk3/COPYING.LGPL
%doc README.md src/gtk3/ATTRIBUTION.md
%{_datadir}/themes/Lyra-Enterprise/
%{_datadir}/themes/Lyra-Enterprise-Light/
%{_datadir}/backgrounds/lyra/enterprise.png
%{_datadir}/backgrounds/lyra/enterprise.jxl
%{_datadir}/backgrounds/lyra/enterprise-light.png
%{_datadir}/backgrounds/lyra/enterprise-light.jxl
%{_datadir}/gnome-background-properties/lyra-enterprise.xml
%{_datadir}/grub/themes/Lyra-Enterprise/

%changelog
* Sun Jul 19 2026 Lyra OS Team <contact@lyraos.dev> - 1.1.0-1
- Keep Adwaita active by default and add the GRUB theme

* Sun Jul 19 2026 Lyra OS Team <contact@lyraos.dev> - 1.0.0-1
- Initial RPM package with dark and light variants
