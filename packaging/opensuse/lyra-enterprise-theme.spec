# Empacotamento para o GitHub Actions (build direto da tag, sem depender do
# _service do OBS) e para o gatilho do openSUSE Build Service
# (home:rodrigosbrito:lyra/lyra-theme, ver .github/workflows/release-opensuse.yml).
# Cópia de packaging/lyra-enterprise-theme.spec adaptada só no Source0/%setup
# pra bater com o tarball "achatado" (sem diretório versionado) que o
# workflow monta com tar czf, ao invés do %autosetup -n %{name}-%{version}
# do spec original. Resto do spec é idêntico.
%{!?version: %define version 0.0.0}

Name:           lyra-enterprise-theme
Version:        %{version}
Release:        1%{?dist}
Summary:        Corporate GNOME, GRUB and Plymouth theme for Lyra OS
License:        GPL-3.0-or-later AND LGPL-2.1-or-later
URL:            https://github.com/britors/Lyra-Theme
Source0:        lyra-theme-src.tar.gz
BuildArch:      noarch
BuildRequires:  ImageMagick
BuildRequires:  nodejs
BuildRequires:  sassc

%description
Corporate, flat GNOME 48+ theme with dark and light variants for GNOME Shell,
GTK 4/libadwaita and GTK 3. Includes matching PNG and JPEG XL wallpapers, the
Lyra Enterprise boot menu theme for GRUB 2, a matching Plymouth boot splash
theme, and a neofetch config with a Lyra ascii logo (installed as a
reference file; copy it into ~/.config/neofetch/config.conf to use it).

%prep
%setup -q -c -n lyra-theme-src

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

install -d %{buildroot}%{_datadir}/plymouth/themes
cp -a dist/plymouth/Lyra-Enterprise %{buildroot}%{_datadir}/plymouth/themes/

install -d %{buildroot}%{_datadir}/%{name}/neofetch
install -m 0644 dist/neofetch/config.conf \
  %{buildroot}%{_datadir}/%{name}/neofetch/config.conf

%files
%license LICENSE src/gtk3/COPYING.LGPL
%doc README.md src/gtk3/ATTRIBUTION.md
%{_datadir}/themes/Lyra-Enterprise/
%{_datadir}/themes/Lyra-Enterprise-Light/
# %dir on backgrounds/gnome-background-properties/grub/plymouth: none of
# these come from a Requires of this package (no grub2/plymouth runtime
# dependency, since the theme is meant to be optional on top of whatever
# bootloader/splash the system already has), so nothing else is
# guaranteed to own the parent dirs — the build's unowned-directory check
# fails without these.
%dir %{_datadir}/backgrounds
%dir %{_datadir}/backgrounds/lyra
%{_datadir}/backgrounds/lyra/enterprise.png
%{_datadir}/backgrounds/lyra/enterprise.jxl
%{_datadir}/backgrounds/lyra/enterprise-light.png
%{_datadir}/backgrounds/lyra/enterprise-light.jxl
%dir %{_datadir}/gnome-background-properties
%{_datadir}/gnome-background-properties/lyra-enterprise.xml
%dir %{_datadir}/grub
%dir %{_datadir}/grub/themes
%{_datadir}/grub/themes/Lyra-Enterprise/
%dir %{_datadir}/plymouth
%dir %{_datadir}/plymouth/themes
%{_datadir}/plymouth/themes/Lyra-Enterprise/
%dir %{_datadir}/%{name}
%dir %{_datadir}/%{name}/neofetch
%{_datadir}/%{name}/neofetch/config.conf

%changelog
