#!/bin/bash

# Ensure script is run as a normal user, not root
if [[ $EUID -eq 0 ]]; then
    echo "DONT run this script as root!"
    exit 1
fi

# Install dependencies
sudo pacman -S --needed base-devel git gtk4 python-gobject

# Check if hyprshot is already installed
if ! command -v hyprshot &> /dev/null; then
    # Clone the AUR repository
    git clone https://aur.archlinux.org/hyprshot.git ~/hyprshot
    cd ~/hyprshot || exit

    # Build and install the package
    makepkg -si

    # Clean up (optional)
    cd .. || exit
    rm -rf ~/hyprshot
else
    echo "Hyprshot is already installed, skipping build."
fi

# Ensure hyprshot-gui is copied
sudo curl -Lo /usr/bin/hyprshot-gui https://raw.githubusercontent.com/s-adi-dev/hyprshot-gui/refs/heads/main/src/hyprshot-gui
sudo curl -Lo /usr/share/applications/hyprshot.desktop https://raw.githubusercontent.com/s-adi-dev/hyprshot-gui/refs/heads/main/src/hyprshot.desktop

echo "Hyprshot installation completed."
