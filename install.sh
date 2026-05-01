#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BACKUP_CONFIG_DIR="$HOME/.config.bak"
BACKUP_HOME_DIR="$HOME/.home.bak"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)

SPECIAL_PACKAGES=(
    bluez
    bluez-utils
    pwvucontrol
    pipewire
    wireplumber
    blueman
)

echo "==> Updating system..."
sudo pacman -Syu --noconfirm

echo "==> Creating backup directories..."
mkdir -p "$BACKUP_CONFIG_DIR"
mkdir -p "$BACKUP_HOME_DIR"

# yay installieren falls nicht vorhanden
if ! command -v yay &> /dev/null; then
    echo "==> Installing yay..."

    sudo pacman -S --needed --noconfirm git base-devel

    TEMP_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay"

    cd "$TEMP_DIR/yay"
    makepkg -si --noconfirm
    cd "$DOTFILES_DIR"

    rm -rf "$TEMP_DIR"
fi

# normale Pakete installieren
if [ -f "$DOTFILES_DIR/packages.txt" ]; then
    echo "==> Installing packages from packages.txt..."

    mapfile -t PACKAGES < <(grep -v '^#' "$DOTFILES_DIR/packages.txt" | grep -v '^$')

    if [ ${#PACKAGES[@]} -gt 0 ]; then
        yay -S --needed --noconfirm "${PACKAGES[@]}"
    fi
fi

# Spezialpakete
echo "==> Installing special packages..."
yay -S --needed --noconfirm "${SPECIAL_PACKAGES[@]}"

# Configs kopieren
echo "==> Backing up and copying config files..."
mkdir -p "$HOME/.config"

for item in "$DOTFILES_DIR"/config/*; do
    [ -e "$item" ] || continue

    name=$(basename "$item")
    target="$HOME/.config/$name"

    if [ -e "$target" ]; then
        echo "Backing up $target"
        mv "$target" "$BACKUP_CONFIG_DIR/${name}_$TIMESTAMP"
    fi

    cp -r "$item" "$target"
    echo "Copied $name -> ~/.config/"
done

# Home Dotfiles kopieren
echo "==> Backing up and copying home dotfiles..."
if [ -d "$DOTFILES_DIR/home" ]; then
    for file in "$DOTFILES_DIR"/home/.*; do
        [ -e "$file" ] || continue

        name=$(basename "$file")

        # . und .. skippen
        [[ "$name" == "." || "$name" == ".." ]] && continue

        target="$HOME/$name"

        if [ -e "$target" ]; then
            echo "Backing up $target"
            mv "$target" "$BACKUP_HOME_DIR/${name}_$TIMESTAMP"
        fi

        cp "$file" "$target"
        echo "Copied $name -> ~/"
    done
fi

# Services
echo "==> Enabling services..."

sudo systemctl enable --now bluetooth.service

systemctl --user enable --now pipewire.service
systemctl --user enable --now pipewire-pulse.service
systemctl --user enable --now wireplumber.service

echo "==> Installation complete!"

read -p "Reboot now? [y/N]: " reboot_choice
if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
    reboot
fi