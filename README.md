# Lyra Enterprise

Identidade visual para GNOME 48+, criada para o Lyra OS e compatível com Fedora,
openSUSE, Arch Linux e distribuições derivadas. A configuração recomendada usa
Adwaita no Shell e nos aplicativos, com ícones e wallpapers Lyra Enterprise.

## Componentes

- Adwaita nativo para GNOME Shell, GTK 4/libadwaita e GTK 3
- Tema vetorial `Lyra-Enterprise-Icons`, com fallback completo para Adwaita
- Wallpapers dark e light em PNG e JPEG XL, 3840×2160
- Tema do GRUB 2 com fundo Full HD e menu de boot Lyra Enterprise
- Pacotes RPM para openSUSE e `PKGBUILD` para Arch/Lyra OS

## Instalação rápida

Revise o [install.sh](install.sh) antes de executá-lo. Para usar Adwaita escuro
com ícones e wallpaper Lyra Enterprise:

```bash
curl --proto '=https' --tlsv1.2 -fsSL \
  https://raw.githubusercontent.com/britors/Lyra-Theme/main/install.sh | bash
```

Variante light:

```bash
curl --proto '=https' --tlsv1.2 -fsSL \
  https://raw.githubusercontent.com/britors/Lyra-Theme/main/install.sh | bash -s -- --light
```

O instalador detecta o gerenciador de pacotes, instala as dependências, compila
os arquivos, instala tema, ícones, wallpapers e GRUB e configura a sessão GNOME
e o menu de boot. A
senha administrativa é solicitada diretamente pelo terminal.

### Opções

```text
--dark          usa Adwaita escuro com ícones e wallpaper Lyra (padrão)
--light         usa Adwaita claro com ícones e wallpaper Lyra
--no-activate   instala sem modificar preferências do GNOME ou do GRUB
--no-grub       não instala nem ativa o tema do GRUB
--uninstall     remove os arquivos e restaura as preferências
--help          mostra a ajuda
```

Exemplo para instalar sem ativação automática:

```bash
curl --proto '=https' --tlsv1.2 -fsSL \
  https://raw.githubusercontent.com/britors/Lyra-Theme/main/install.sh | bash -s -- --no-activate
```

## Requisitos

- GNOME 48 ou superior
- `curl`, `tar`, `xz`, `sassc`, Node.js e ImageMagick 7 com suporte a JXL

O instalador resolve esses pacotes automaticamente em Fedora, openSUSE, Arch e
Debian/Ubuntu.

## Build a partir do repositório

```bash
git clone https://github.com/britors/Lyra-Theme.git
cd Lyra-Theme
./scripts/build.sh
./scripts/build-icons.sh
./scripts/package.sh
```

Os resultados são gravados em `dist/`. O último comando também gera
`Lyra-Enterprise.tar.xz`. O build executa automaticamente a validação WCAG das
paletas dark e light.

Para compilar e instalar diretamente a partir deste checkout (sem baixar um
tarball do GitHub), use:

```bash
./scripts/install-local.sh
```

Aceita as mesmas opções do `install.sh` (`--dark`, `--light`,
`--no-activate`, `--no-grub`, `--uninstall`), mas não instala dependências de
build automaticamente — instale `sassc`, Node.js e ImageMagick antes de
executá-lo.

## Instalação manual

```bash
sudo install -d /usr/share/themes /usr/share/icons \
  /usr/share/backgrounds/lyra /usr/share/gnome-background-properties \
  /usr/share/grub/themes
sudo cp -a dist/Lyra-Enterprise dist/Lyra-Enterprise-Light /usr/share/themes/
sudo cp -a dist/Lyra-Enterprise-Icons /usr/share/icons/
sudo install -m 0644 dist/backgrounds/*.{png,jxl} /usr/share/backgrounds/lyra/
sudo install -m 0644 dist/gnome-background-properties/lyra-enterprise.xml \
  /usr/share/gnome-background-properties/
sudo cp -a dist/grub/Lyra-Enterprise /usr/share/grub/themes/
```

## Ativação manual

### Adwaita com ícones Lyra Enterprise

```bash
gsettings reset org.gnome.shell.extensions.user-theme name
gsettings reset org.gnome.desktop.interface gtk-theme
gsettings set org.gnome.desktop.interface icon-theme 'Lyra-Enterprise-Icons'
gsettings set org.gnome.desktop.interface accent-color 'blue'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
```

O GNOME Shell e os aplicativos permanecem no Adwaita padrão; somente os ícones
são fornecidos pelo Lyra Enterprise. Isso mantém compatibilidade integral com
os controles rápidos das versões atuais do GNOME.

### Variante clara

Use:

```bash
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
```

### GRUB

O instalador ativa o tema em `/etc/default/grub` e regenera o `grub.cfg`. Para
ativá-lo manualmente, acrescente:

```bash
GRUB_THEME="/usr/share/grub/themes/Lyra-Enterprise/theme.txt"
```

Depois execute `sudo update-grub` (Debian/Ubuntu), ou
`sudo grub2-mkconfig -o /boot/grub2/grub.cfg` (Fedora/openSUSE), ou
`sudo grub-mkconfig -o /boot/grub/grub.cfg` (Arch). O instalador só remove essa
configuração na desinstalação se ela ainda apontar para o tema Lyra.

## Pacotes

### Fedora / RPM

O Fedora recebe um único pacote com temas, ícones e wallpapers. A especificação
está em `packaging/lyra-enterprise-fedora.spec`.

Para instalar o RPM pré-compilado incluído no repositório:

```bash
sudo dnf install ./lyra-enterprise-1.0.0-1.noarch.rpm
```

SHA-256: `c239e72a88d26c6db39972c2c5b78599f01ea9f21cf40c927e987f7e55bf28ff`

Para reconstruí-lo no Fedora:

```bash
sudo dnf install -y rpm-build rpmdevtools ImageMagick nodejs sassc \
  adwaita-icon-theme
rpmdev-setuptree
cp packaging/lyra-enterprise-fedora.spec ~/rpmbuild/SPECS/
rpmbuild -bb ~/rpmbuild/SPECS/lyra-enterprise-fedora.spec
sudo dnf install ~/rpmbuild/RPMS/noarch/lyra-enterprise-1.1.0-1*.noarch.rpm
```

### openSUSE / RPM

As especificações estão em:

- `packaging/lyra-enterprise-theme.spec`
- `packaging/lyra-enterprise-icons.spec`

Exemplo de build no ambiente padrão do RPM:

```bash
rpmbuild -bb packaging/lyra-enterprise-theme.spec
rpmbuild -bb packaging/lyra-enterprise-icons.spec
```

### Arch Linux / Lyra OS

Use `packaging/PKGBUILD` com `makepkg -si`. O pacote usa Adwaita como fallback
dos ícones e não executa hooks que alterem configurações pessoais.

## Estrutura

```text
src/shell/       tokens SCSS e tema GNOME Shell
src/gtk4/        overrides GTK 4/libadwaita
src/gtk3/        port GTK 3 e atribuição LGPL
src/icons/       tema de ícones SVG
src/wallpaper/   fonte vetorial e metadados GNOME
src/grub/        tema, fundo e seleção do menu GRUB
scripts/         build, validação e empacotamento
packaging/       PKGBUILD e especificações RPM
```

## Desinstalação

```bash
curl --proto '=https' --tlsv1.2 -fsSL \
  https://raw.githubusercontent.com/britors/Lyra-Theme/main/install.sh | bash -s -- --uninstall
```

## Licenças

O projeto é distribuído sob GPL-3.0-or-later. O componente GTK 3 mantém
LGPL-2.1-or-later e a atribuição ao adw-gtk3 em
`src/gtk3/ATTRIBUTION.md`. O tema não substitui fontes, não modifica GDM e não
altera configurações do usuário durante a instalação por pacote.
