# Lyra Enterprise

Tema oficial corporativo do Lyra OS para GNOME 48 ou superior. Inclui variantes
dark e light para GNOME Shell, GTK 4/libadwaita, GTK 3, além de wallpaper em PNG
e JPEG XL. O visual usa superfícies planas, acento azul-safira único e foco de
teclado de alto contraste.

## Dependências

- GNOME 48+
- `gnome-shell-extension-user-theme` (execução)
- `sassc` e ImageMagick com suporte a JXL (build)

No Arch/Lyra OS:

```bash
sudo pacman -S gnome-shell-extension-user-theme sassc imagemagick
```

## Build e pacote portátil

```bash
./scripts/build.sh
./scripts/package.sh
```

O primeiro comando recria `dist/`; o segundo gera `Lyra-Enterprise.tar.xz` com
as duas variantes e os wallpapers. A validação WCAG é executada como parte do
build. Em ambientes de desenvolvimento sem `sassc`, o script possui um fallback
limitado aos tokens usados neste projeto; o `PKGBUILD` sempre usa `sassc`.

## Instalação manual

```bash
sudo install -d /usr/share/themes /usr/share/backgrounds/lyra /usr/share/gnome-background-properties
sudo cp -a dist/Lyra-Enterprise dist/Lyra-Enterprise-Light /usr/share/themes/
sudo install -m644 dist/backgrounds/*.{png,jxl} /usr/share/backgrounds/lyra/
sudo install -m644 dist/gnome-background-properties/lyra-enterprise.xml /usr/share/gnome-background-properties/
```

Alternativamente, copie `packaging/PKGBUILD` para um diretório de build, ajuste
o checksum para a tag publicada e execute `makepkg -si`.

### openSUSE / RPM

O arquivo `packaging/lyra-enterprise-theme.spec` gera um pacote RPM nativo. Com
as dependências de build instaladas:

```bash
rpmbuild -bb packaging/lyra-enterprise-theme.spec
sudo zypper install ~/rpmbuild/RPMS/noarch/lyra-enterprise-theme-1.0.0-1*.noarch.rpm
```

## Ativação dark

Ative primeiro a extensão User Themes pelo aplicativo Extensões. Em seguida:

```bash
gsettings set org.gnome.shell.extensions.user-theme name 'Lyra-Enterprise'
gsettings set org.gnome.desktop.interface gtk-theme 'Lyra-Enterprise'
gsettings set org.gnome.desktop.interface accent-color 'blue'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
mkdir -p ~/.config/gtk-4.0
ln -sf /usr/share/themes/Lyra-Enterprise/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk.css
```

Encerre e abra novamente aplicativos GTK já em execução. Para aplicar ao Shell,
encerre a sessão e entre novamente caso a extensão não recarregue o tema.

## Ativação light

Use `Lyra-Enterprise-Light` nos comandos de Shell, GTK 3 e no caminho do symlink,
e defina:

```bash
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
```

## Restaurar o padrão

```bash
rm ~/.config/gtk-4.0/gtk.css
gsettings reset org.gnome.shell.extensions.user-theme name
gsettings reset org.gnome.desktop.interface gtk-theme
gsettings reset org.gnome.desktop.interface color-scheme
```

Remover o symlink restaura o stylesheet GTK 4/libadwaita sem deixar arquivos do
tema na configuração do usuário. O pacote não executa hooks nem altera qualquer
preferência automaticamente.

## Fonte opcional

O tema não impõe fontes. Para usar Inter, instale-a separadamente e ajuste pelas
Configurações/Ajustes do GNOME ou via `gsettings` conforme a política local.

## Licenças

O projeto é GPL-3.0-or-later. O componente GTK 3 preserva LGPL-2.1-or-later e a
atribuição ao adw-gtk3 em `src/gtk3/ATTRIBUTION.md`.
