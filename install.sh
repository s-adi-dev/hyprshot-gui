#!/bin/bash

# Ensure script is run as a normal user, not root
if [[ $EUID -eq 0 ]]; then
    echo "Please do not run this script as root."
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
    cd ..
    rm -rf ~/hyprshot
else
    echo "Hyprshot is already installed, skipping build."
fi

# Ensure hyprshot-gui is copied
sudo cp ./src/hyprshot-gui /usr/bin/hyprshot-gui
sudo cp ./src/hyprshot.desktop /usr/share/applications/hyprshot.desktop

echo "Hyprshot installation completed."
