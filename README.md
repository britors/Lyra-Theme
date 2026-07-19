# Lyra Enterprise

Tema corporativo para GNOME 48+, criado para o Lyra OS e compatível com Fedora,
openSUSE, Arch Linux e distribuições derivadas. O projeto oferece uma interface
sóbria, plana e profissional, com superfícies neutras e acento azul-safira.

## Componentes

- GNOME Shell: painel opaco, Quick Settings, overview, dash, diálogos e OSD
- GTK 4/libadwaita: cores nomeadas, raio de 8 px e foco acessível
- GTK 3: port compatível baseado nas convenções do adw-gtk3
- Variantes `Lyra-Enterprise` e `Lyra-Enterprise-Light`
- Tema vetorial `Lyra-Enterprise-Icons`, com fallback completo para Adwaita
- Wallpapers dark e light em PNG e JPEG XL, 3840×2160
- Pacotes RPM para openSUSE e `PKGBUILD` para Arch/Lyra OS

## Instalação rápida

Revise o [install.sh](install.sh) antes de executá-lo. Para instalar e ativar a
variante dark:

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
os arquivos, instala tema, ícones e wallpapers e configura a sessão GNOME. A
senha administrativa é solicitada diretamente pelo terminal.

### Opções

```text
--dark          instala e ativa a variante dark (padrão)
--light         instala e ativa a variante light
--no-activate   instala sem modificar preferências do GNOME
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
- extensão User Themes
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

## Instalação manual

```bash
sudo install -d /usr/share/themes /usr/share/icons \
  /usr/share/backgrounds/lyra /usr/share/gnome-background-properties
sudo cp -a dist/Lyra-Enterprise dist/Lyra-Enterprise-Light /usr/share/themes/
sudo cp -a dist/Lyra-Enterprise-Icons /usr/share/icons/
sudo install -m 0644 dist/backgrounds/*.{png,jxl} /usr/share/backgrounds/lyra/
sudo install -m 0644 dist/gnome-background-properties/lyra-enterprise.xml \
  /usr/share/gnome-background-properties/
```

## Ativação manual

### Dark

```bash
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gsettings set org.gnome.shell.extensions.user-theme name 'Lyra-Enterprise'
gsettings set org.gnome.desktop.interface gtk-theme 'Lyra-Enterprise'
gsettings set org.gnome.desktop.interface icon-theme 'Lyra-Enterprise-Icons'
gsettings set org.gnome.desktop.interface accent-color 'blue'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
mkdir -p ~/.config/gtk-4.0
ln -sfn /usr/share/themes/Lyra-Enterprise/gtk-4.0/gtk.css \
  ~/.config/gtk-4.0/gtk.css
```

### Light

Troque `Lyra-Enterprise` por `Lyra-Enterprise-Light` nos comandos do tema e no
symlink, e use:

```bash
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
```

Após instalar a extensão User Themes pela primeira vez, encerre a sessão e
entre novamente para o GNOME Shell atualizar seu catálogo de extensões.

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
  gnome-shell-extension-user-theme
rpmdev-setuptree
cp packaging/lyra-enterprise-fedora.spec ~/rpmbuild/SPECS/
rpmbuild -bb ~/rpmbuild/SPECS/lyra-enterprise-fedora.spec
sudo dnf install ~/rpmbuild/RPMS/noarch/lyra-enterprise-1.0.0-1*.noarch.rpm
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

Use `packaging/PKGBUILD` com `makepkg -si`. O pacote declara a extensão User
Themes como dependência e não executa hooks que alterem configurações pessoais.

## Estrutura

```text
src/shell/       tokens SCSS e tema GNOME Shell
src/gtk4/        overrides GTK 4/libadwaita
src/gtk3/        port GTK 3 e atribuição LGPL
src/icons/       tema de ícones SVG
src/wallpaper/   fonte vetorial e metadados GNOME
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
