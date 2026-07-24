# Lyra Enterprise

Identidade visual para GNOME 48+, criada para o Lyra OS e para openSUSE. A
configuração recomendada usa Adwaita no Shell e nos aplicativos, com ícones e
wallpapers Lyra Enterprise.

## Componentes

- Adwaita nativo para GNOME Shell, GTK 4/libadwaita e GTK 3
- Tema vetorial `Lyra-Enterprise-Icons`, com fallback completo para Adwaita
- Wallpapers dark e light em PNG e JPEG XL, 3840×2160
- Tema do GRUB 2 com fundo Full HD e menu de boot Lyra Enterprise
- Tema de boot do Plymouth com o mesmo fundo e logo do GRUB
- Configs do Fastfetch e Neofetch com logo ascii da Lyra e cores da marca
- Pacotes RPM para openSUSE

## Instalação rápida

Revise o [install.sh](install.sh) antes de executá-lo. Requer openSUSE
(`zypper`). Para usar Adwaita escuro com ícones e wallpaper Lyra Enterprise:

```bash
curl --proto '=https' --tlsv1.2 -fsSL \
  https://raw.githubusercontent.com/britors/Lyra-Theme/main/install.sh | bash
```

Variante light:

```bash
curl --proto '=https' --tlsv1.2 -fsSL \
  https://raw.githubusercontent.com/britors/Lyra-Theme/main/install.sh | bash -s -- --light
```

### Instalação pelos pacotes RPM

Para adicionar o repositório OBS, instalar os RPMs e ativar automaticamente
os ícones, wallpapers, GRUB, Plymouth e as configurações do Fastfetch e
Neofetch:

```bash
curl --proto '=https' --tlsv1.2 -fsSL \
  https://raw.githubusercontent.com/britors/Lyra-Theme/main/install-rpm.sh | bash
```

Para usar a variante clara:

```bash
curl --proto '=https' --tlsv1.2 -fsSL \
  https://raw.githubusercontent.com/britors/Lyra-Theme/main/install-rpm.sh | bash -s -- --light
```

O instalador instala as dependências via `zypper`, compila os arquivos,
instala tema, ícones, wallpapers, GRUB e Plymouth, ativa Adwaita com os
ícones Lyra Enterprise no GNOME, o menu de boot do GRUB e o splash de boot do
Plymouth, e copia os configs do Fastfetch e Neofetch com o logo ascii da Lyra
para o perfil atual. Configurações existentes recebem um backup antes da
substituição. A senha administrativa é solicitada diretamente pelo terminal.

### Opções

```text
--dark          usa Adwaita escuro com ícones e wallpaper Lyra (padrão)
--light         usa Adwaita claro com ícones e wallpaper Lyra
--no-activate   instala sem modificar preferências do GNOME, do GRUB, do
                Plymouth ou os configs do Fastfetch e Neofetch
--no-grub       não instala nem ativa o tema do GRUB
--no-plymouth   não instala nem ativa o tema do Plymouth
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
- openSUSE, com `zypper`
- `curl`, `tar`, `xz`, `sassc`, Node.js, `rsvg-convert` e ImageMagick 7 com
  suporte a JXL

O instalador resolve esses pacotes automaticamente via `zypper`.

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
`--no-activate`, `--no-grub`, `--no-plymouth`, `--uninstall`), mas não instala
dependências de build automaticamente — instale `sassc`, Node.js e
`rsvg-convert` e ImageMagick antes de executá-lo.

## Instalação manual

```bash
sudo install -d /usr/share/themes /usr/share/icons \
  /usr/share/backgrounds/lyra /usr/share/gnome-background-properties \
  /usr/share/grub/themes /usr/share/plymouth/themes \
  /usr/share/lyra-enterprise-theme/fastfetch
sudo cp -a dist/Lyra-Enterprise dist/Lyra-Enterprise-Light /usr/share/themes/
sudo cp -a dist/Lyra-Enterprise-Icons /usr/share/icons/
sudo install -m 0644 dist/backgrounds/*.{png,jxl} /usr/share/backgrounds/lyra/
sudo install -m 0644 dist/gnome-background-properties/lyra-enterprise.xml \
  /usr/share/gnome-background-properties/
sudo cp -a dist/grub/Lyra-Enterprise /usr/share/grub/themes/
sudo cp -a dist/plymouth/Lyra-Enterprise /usr/share/plymouth/themes/
sudo cp -a dist/fastfetch/. /usr/share/lyra-enterprise-theme/fastfetch/
mkdir -p ~/.config/neofetch
cp dist/neofetch/config.conf ~/.config/neofetch/config.conf
mkdir -p ~/.config/fastfetch
cp dist/fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc
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

O instalador ativa o tema em `/etc/default/grub` e regenera o `grub.cfg` com
`grub2-mkconfig`. Para ativá-lo manualmente, acrescente:

```bash
GRUB_THEME="/usr/share/grub/themes/Lyra-Enterprise/theme.txt"
```

Depois execute `sudo grub2-mkconfig -o /boot/grub2/grub.cfg`. O instalador só
remove essa configuração na desinstalação se ela ainda apontar para o tema
Lyra.

### Plymouth

O instalador ativa o tema com `plymouth-set-default-theme -R Lyra-Enterprise`
(o `-R` já regenera o initramfs) quando esse comando está disponível, e
guarda o tema anterior para restaurá-lo na desinstalação. Para ativar
manualmente:

```bash
sudo plymouth-set-default-theme -R Lyra-Enterprise
```

### neofetch

O config em `src/neofetch/config.conf` (copiado para
`~/.config/neofetch/config.conf` pelo instalador) troca o logo ascii pelo
mark da Lyra com a legenda `Lyra Linux 1.0 - ODISSEIA`, colorido com a
paleta da marca, mantendo o resto das opções padrão do neofetch. Para
aplicá-lo manualmente:

```bash
mkdir -p ~/.config/neofetch
cp dist/neofetch/config.conf ~/.config/neofetch/config.conf
```

### Fastfetch

O config em `src/fastfetch/config.jsonc` usa o logo ascii Lyra localizado em
`/usr/share/lyra-enterprise-theme/fastfetch/logo.txt`, com a legenda
`Lyra Linux 1.0 - ODISSEIA`. O instalador cria um backup do config atual
antes de ativá-lo. Para aplicar manualmente:

```bash
mkdir -p ~/.config/fastfetch
cp dist/fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc
```

## Pacotes

### openSUSE / RPM

As especificações estão em:

- `packaging/lyra-enterprise-theme.spec`
- `packaging/lyra-enterprise-icons.spec`

Exemplo de build no ambiente padrão do RPM:

```bash
rpmbuild -bb packaging/lyra-enterprise-theme.spec
rpmbuild -bb packaging/lyra-enterprise-icons.spec
```

O pacote ativa os temas do GRUB e do Plymouth e instala os ícones e wallpapers
como padrões do GNOME. Perfis existentes que já tenham preferências próprias
não são sobrescritos pelo RPM. Os configs do Fastfetch e Neofetch são
instalados em `/etc/skel` para novos usuários e como referências em
`/usr/share/lyra-enterprise-theme/`. Use o `install-rpm.sh` acima para aplicar
todas essas configurações também ao usuário atual.

## Estrutura

```text
src/shell/       tokens SCSS e tema GNOME Shell
src/gtk4/        overrides GTK 4/libadwaita
src/gtk3/        port GTK 3 e atribuição LGPL
src/icons/       tema de ícones SVG
src/wallpaper/   fonte vetorial e metadados GNOME
src/grub/        tema, fundo e seleção do menu GRUB
src/plymouth/    script, logo e barra de progresso do tema Plymouth
src/neofetch/    config do neofetch com logo ascii da Lyra
src/fastfetch/   config e logo ascii para o Fastfetch
scripts/         build, validação e empacotamento
packaging/       especificações RPM
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
