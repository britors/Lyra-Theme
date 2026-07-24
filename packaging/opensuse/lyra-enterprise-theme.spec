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
Requires:       lyra-enterprise-icons
Requires(post): grub2
Requires(preun): grub2
Requires(post): plymouth-scripts
Requires(preun): plymouth-scripts
Recommends:     neofetch

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

install -d %{buildroot}%{_datadir}/glib-2.0/schemas
install -m 0644 src/defaults/99-lyra-enterprise.gschema.override \
  %{buildroot}%{_datadir}/glib-2.0/schemas/

install -d %{buildroot}%{_datadir}/grub/themes
cp -a dist/grub/Lyra-Enterprise %{buildroot}%{_datadir}/grub/themes/

install -d %{buildroot}%{_datadir}/plymouth/themes
cp -a dist/plymouth/Lyra-Enterprise %{buildroot}%{_datadir}/plymouth/themes/

install -d %{buildroot}%{_datadir}/%{name}/neofetch
install -m 0644 dist/neofetch/config.conf \
  %{buildroot}%{_datadir}/%{name}/neofetch/config.conf

install -d %{buildroot}%{_sysconfdir}/skel/.config/neofetch
install -m 0644 dist/neofetch/config.conf \
  %{buildroot}%{_sysconfdir}/skel/.config/neofetch/config.conf

%post
grub_default=%{_sysconfdir}/default/grub
grub_backup=%{_localstatedir}/lib/%{name}/grub-theme.backup
plymouth_backup=%{_localstatedir}/lib/%{name}/plymouth-theme.backup
lyra_theme='GRUB_THEME="%{_datadir}/grub/themes/Lyra-Enterprise/theme.txt"'

install -d -m 0755 %{_localstatedir}/lib/%{name}

if [ -f "$grub_default" ]; then
  if [ "$1" -eq 1 ]; then
    grep '^[[:space:]]*GRUB_THEME=' "$grub_default" > "$grub_backup" || :
  fi
  sed -i '/^[[:space:]]*GRUB_THEME=/d' "$grub_default"
  printf '%s\n' "$lyra_theme" >> "$grub_default"
  %{_sbindir}/grub2-mkconfig -o /boot/grub2/grub.cfg || :
fi

if [ "$1" -eq 1 ]; then
  %{_sbindir}/plymouth-set-default-theme > "$plymouth_backup" || :
fi
%{_sbindir}/plymouth-set-default-theme -R Lyra-Enterprise || :

%preun
if [ "$1" -eq 0 ]; then
  grub_default=%{_sysconfdir}/default/grub
  grub_backup=%{_localstatedir}/lib/%{name}/grub-theme.backup
  plymouth_backup=%{_localstatedir}/lib/%{name}/plymouth-theme.backup
  lyra_theme='GRUB_THEME="%{_datadir}/grub/themes/Lyra-Enterprise/theme.txt"'

  if [ -f "$grub_default" ] && grep -Fqx "$lyra_theme" "$grub_default"; then
    sed -i '\|^[[:space:]]*GRUB_THEME="/usr/share/grub/themes/Lyra-Enterprise/theme.txt"$|d' "$grub_default"
    if [ -s "$grub_backup" ]; then
      cat "$grub_backup" >> "$grub_default"
    fi
    %{_sbindir}/grub2-mkconfig -o /boot/grub2/grub.cfg || :
  fi

  if [ "$(%{_sbindir}/plymouth-set-default-theme 2>/dev/null)" = "Lyra-Enterprise" ]; then
    if [ -s "$plymouth_backup" ]; then
      read -r previous_plymouth < "$plymouth_backup"
      %{_sbindir}/plymouth-set-default-theme -R "$previous_plymouth" || :
    else
      %{_sbindir}/plymouth-set-default-theme -R --reset || :
    fi
  fi

  rm -f "$grub_backup"
  rm -f "$plymouth_backup"
  rmdir %{_localstatedir}/lib/%{name} 2>/dev/null || :
fi

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
%{_datadir}/glib-2.0/schemas/99-lyra-enterprise.gschema.override
%dir %{_datadir}/grub
%dir %{_datadir}/grub/themes
%{_datadir}/grub/themes/Lyra-Enterprise/
%dir %{_datadir}/plymouth
%dir %{_datadir}/plymouth/themes
%{_datadir}/plymouth/themes/Lyra-Enterprise/
%dir %{_datadir}/%{name}
%dir %{_datadir}/%{name}/neofetch
%{_datadir}/%{name}/neofetch/config.conf
%dir %{_sysconfdir}/skel/.config
%dir %{_sysconfdir}/skel/.config/neofetch
%config(noreplace) %{_sysconfdir}/skel/.config/neofetch/config.conf

%changelog
