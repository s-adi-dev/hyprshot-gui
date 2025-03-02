#!/bin/bash

# Ensure script is run as a normal user, not root
if [[ $EUID -eq 0 ]]; then
    echo "Please do not run this script as root."
    exit 1
fi

# Install dependencies
sudo pacman -S --needed base-devel git gtk4 python-gobject

# Clone the AUR repository
git clone https://aur.archlinux.org/hyprshot.git ~/hyprshot
cd ~/hyprshot || exit

# Build and install the package
makepkg -si

# Clean up (optional)
cd ..
rm -rf ~/hyprshot

echo "Hyprshot installation completed."
