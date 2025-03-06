#!/bin/bash

# Ensure script is run as a normal user, not root
if [[ $EUID -eq 0 ]]; then
    echo "DONT run this script as root!"
    exit 1
fi

arch() {
    # Install dependencies
    sudo pacman -S --needed base-devel git gtk4 python-gobject curl

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
    echo "Installing the program..."
    sudo curl -s -o /usr/bin/hyprshot-gui https://raw.githubusercontent.com/s-adi-dev/hyprshot-gui/refs/heads/main/src/hyprshot-gui
    echo "Adding the program to the applications list..."
    sudo curl -s -o /usr/share/applications/hyprshot.desktop https://raw.githubusercontent.com/s-adi-dev/hyprshot-gui/refs/heads/main/src/hyprshot.desktop
}

other() {

    if ! command -v hyprshot &> /dev/null; then
        echo "You need to install hyprshot!"
        end
    fi

    # Check if python is already installed
    if ! command -v python3 &> /dev/null || ! command -v python &> /dev/null; then
        echo "You need to install python!"
        exit
    fi

    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        echo "cURL or wget are installed! Install one of the two!"
        exit
    fi
    
    # Check if python is already installed
    if ! command -v curl &> /dev/null; then
        echo "cURL is not installed using wget!"
        echo "Installing the program..."
        sudo wget -qO /usr/bin/hyprshot-gui https://raw.githubusercontent.com/s-adi-dev/hyprshot-gui/refs/heads/main/src/hyprshot-gui
        echo "Adding the program to the applications list..."
        sudo wget -qO /usr/share/applications/hyprshot.desktop https://raw.githubusercontent.com/s-adi-dev/hyprshot-gui/refs/heads/main/src/hyprshot.desktop
    else
        echo "Installing the program..."
        sudo curl -s -o /usr/bin/hyprshot-gui https://raw.githubusercontent.com/s-adi-dev/hyprshot-gui/refs/heads/main/src/hyprshot-gui
        echo "Adding the program to the applications list..."
        sudo curl -s -o /usr/share/applications/hyprshot.desktop https://raw.githubusercontent.com/s-adi-dev/hyprshot-gui/refs/heads/main/src/hyprshot.desktop
    fi
}


case "$1" in
"arch")
    arch
    ;;
"other")
    other
    ;;
*)
    while true; do
        read -r -p "Are you using Arch Linux or not? [y/n] " yes < /dev/tty
        case "$yes" in
        [Nn]) 
            other
            break
            ;;
        [Yy])
            arch
            break
            ;;
        *)
            echo -e "You NEED to input either \033[0;32mY\033[0m, \033[0;32my\033[0m, \033[0;31mN\033[0m or \033[0;31mn\033[0m!"
            ;;
        esac
    done
esac

echo "windowrulev2 = float, title:^(.*Hyprshot.*)$" >> ~/.config/hypr/hyprland.conf
echo -e"[Settings]\rOutputDir=\~\/Pictures\rDelay=0\rNotifyTimeout=5000\rClipboardOnly=False\rFreeze=False\rSilent=False
" >> ~/.config/hypr/hyprshot.conf
echo "Hyprshot installation completed."
