#!/usr/bin/env bash
#{{{ Bash settings
set -o errexit
set -o nounset
set -o pipefail
set -o errtrace
#}}}
#######################################
# Runs everything
#######################################
main() {

    # Sets which priviledges elevator to use
    if [[ "${USER}" != root ]]; then
        # checks if doas is installed and use it as default
        command -v doas >/dev/null && PRIVUP="doas" || PRIVUP="sudo"
    fi

    local HGUI_REMOTE
    local HGUI_EXEC
    local HGUI_DESK
    local HGUI_DEST
    local REMOTE_EXEC
    local REMOTE_DESK
    local HGUI_CONF
    local H_EXEC
    local H_DEST
    local HYPRSHOT_URL
    local TEMP_DIR

    BASE_URL="https://raw.githubusercontent.com"
    HGUI_REMOTE="${BASE_URL}/s-adi-dev/hyprshot-gui/refs/heads/main/src"
    HGUI_EXEC="hyprshot-gui"
    HGUI_DESK="hyprshot.desktop"
    HGUI_DEST="/usr/bin/${HGUI_EXEC}"
    HGUI_DESK_DEST="/usr/share/applications/${HGUI_DESK}"
    HGUI_CONF="${HOME}/.config/hypr/hyprshot.conf"
    REMOTE_EXEC="${HGUI_REMOTE}/${HGUI_EXEC}"
    REMOTE_DESK="${HGUI_REMOTE}/${HGUI_DESK}"
    H_EXEC="hyprshot"
    H_DEST="/usr/bin/${H_EXEC}"
    HYPRSHOT_URL="${BASE_URL}/gustash/hyprshot/refs/heads/main/${H_EXEC}"
    TEMP_DIR="$(mktemp --directory --suffix -HYPRSHOT-GUI)"

    super_user_check
    hyprshot_requirements "$(which_distro_is_this)"
    hyprshot_obtain_raw
    hyprshot_installation "${@}"
    hyprshot_defaults "${@}"
    window_float_rule

}
#######################################
# Detects which distro is running
# Not all distro comes with lsb_release installed
#######################################
which_distro_is_this() {

    local -a os_release_file
    local -A distro_info
    os_release_file=""
    # sets which release file to use
    [[ -e /etc/os-release ]] && os_release_file='/etc/os-release' || os_release_file='/usr/lib/os-release'
    # returns fedora,debian,cachyos etc
    short="$(sed --sandbox --silent --regexp-extended 's#^ID=(.*)$#\1#p' "${os_release_file}" | xargs)"
    # returns Fedora Linux, Debian GNU/Linux, CachyOS Linux etc
    name="$(sed --sandbox --silent --regexp-extended 's#^NAME=(.*)$#\1#p' "${os_release_file}" | xargs)"
    distro_info=(
        [${short}]=${name}
    )

    printf "%s\n%s\n" "${!distro_info[*]}" "${distro_info[${short}]}"

}
#######################################
# Based on which_distro_is_this return installs the dependencies
#######################################
hyprshot_requirements() {

    local -a distro_info
    local short
    local long

    readarray -t distro_info < <(which_distro_is_this)
    short="${distro_info[0]}"
    long="${distro_info[1]}"

    printf "Detected ID %s or a %s based OS: %s\n" "${short}" "${short}" "${long}"
    printf "Installing dependencies for %s...\n\n" "${long}"

    case "${short}" in
    arch | cachyos)
        "${PRIVUP}" pacman --sync --needed git gtk4 python-gobject curl
        ;;
    fedora | nobara)
        "${PRIVUP}" dnf --assumeyes install git gtk4 python3-gobject curl
        ;;
    suse | opensuse)
        "${PRIVUP}" zypper --no-confirm install git curl python3-gobject
        ;;
    ubuntu | mint | pop)
        "${PRIVUP}" apt --assume-yes install git curl python3-gobject
        ;;
    *)
        printf "%s (%s) is not on the list\n" "${long}" "${short}"
        ;;
    esac

}
#######################################
# Checks if priviledges where elevated and exits if true
#######################################
super_user_check() {
    local user_id
    local user_name

    user_id="$(id --user --real)"
    user_name="$(id --user --name)"

    if [[ "${user_id}" -eq 0 ]]; then
        printf "This script is not intended to be used with elevated privileges (%s). Exiting." "${user_name}"
        exit 1
    fi
}
#######################################
# Generates the configuration file with its defaults
#######################################
hyprshot_defaults() {

    local configuration_defaults
    configuration_defaults="[Settings]
OutputDir = ${XDG_PICTURES_DIR}
Delay = 0
NotifyTimeout = 5000
ClipboardOnly = False
Freeze = False
Silent = False
"

    if [[ ! -s "${HGUI_CONF}" ]]; then
        printf "Creating the config %s...\n" "${HGUI_CONF}"
        printf "%b" "${configuration_defaults}" | tee -p --ignore-interrupts "${HGUI_CONF}"
    fi
}
#######################################
# Directly downloads hyprshot, hyprshot-gui and its desktop file to a temporary folder
#######################################
hyprshot_obtain_raw() {

    local -A wanted
    local -ga DOWNLOADED

    wanted=(
        [${H_EXEC}]=${HYPRSHOT_URL}
        [${HGUI_EXEC}]=${REMOTE_EXEC}
        [${HGUI_DESK}]=${REMOTE_DESK}
    )

    for w in "${!wanted[@]}"; do
        printf "\nObtaining %s \n\tfrom %s...\n" "${w}" "${wanted[${w}]}"
        curl --silent --location --progress-bar --continue-at - "${wanted[${w}]}" --output "${TEMP_DIR}/${w}"
        DOWNLOADED+=("${TEMP_DIR}/${w}")
    done

}
#######################################
# Installs downloaded files
#######################################
hyprshot_installation() {

    # local hyprshot_ver
    # local hyprshotgui_ver
    # hyprshot_ver="$(hyprshot --version)"
    # hyprshotgui_ver="$(hyprshot-gui --version)"

    printf "\nInstalling Hyprshot... (%s)\n" "${H_EXEC}"
    "${PRIVUP}" install --verbose --compare --mode 755 "${TEMP_DIR}/${H_EXEC}" "${H_DEST}"

    printf "\nInstalling HyprShot GUI... (%s)\n" "${HGUI_EXEC}"
    "${PRIVUP}" install --verbose --compare --mode 755 "${TEMP_DIR}/${HGUI_EXEC}" "${HGUI_DEST}"

    printf "\nCopying HyprShot GUI desktop file... (%s)\n" "${HGUI_DESK}"
    "${PRIVUP}" cp --verbose "${TEMP_DIR}/${HGUI_DESK}" "${HGUI_DESK_DEST}"

    printf "\nInstallation process complete!\n\n"
}
#######################################
# Checks if there is the window rule to float HyprShot GUI window, adds it if it doesn't.
# Backs up the configuration file in the process
#######################################
window_float_rule() {

    local -a config_files
    local rule_file
    local window_rule
    local which_line
    local hyprland_version

    mapfile -t config_files < <(grep --files-with-matches --extended-regexp --recursive "windowrule" "${HOME}/.config/hypr/")
    hyprland_version="$(hyprland --version | awk 'NR==1 {print $2}' | cut --delimiter="." --fields=2 | tr --delete "\n")"
    if [[ "${hyprland_version}" -gt 47 ]]; then
        window_rule="windowrule = float, title:^(.*Hyprshot.*)$"
    else
        window_rule="windowrulev2 = float, title:^(.*Hyprshot.*)$"
    fi
    key_line="# HyprShot GUI floating"
    if [[ ${#config_files[@]} -ne 1 ]]; then
        printf "%s\n" "Can't figure out which file holds your windows rules."
        printf "\t%b\n" "${config_files[*]}"
        printf "%b\n%b" "${key_line}" "${window_rule}" | wl-copy
        printf "Paste this inside your window rules file [already copied to memory]: \n\t%b\n\t%b\n" "${key_line}" "${window_rule}"
        exit 1
    elif [[ ${#config_files[@]} -eq 1 ]]; then
        rule_file="${config_files[0]}"
    fi
    which_line="$(grep --fixed-string --line-number "${window_rule}" "${rule_file[0]}" | cut --delimiter=":" --fields=1)"

    if grep --extended-regexp --only-matching "${window_rule}" "${rule_file[0]}"; then
        printf "It looks like %s already has the configuration at line %s." "${rule_file}" "${which_line}"
    else
        printf "Backing up %s\n" "${rule_file[0]}"
        cp --verbose "${rule_file[0]}"{,.HYPRSHOTGUI}
        printf "Appending window rule to the end of %s\n" "${rule_file[0]}"
        printf "\n%s\n%s\n" "${key_line}" "${window_rule}" | tee --append --ignore-interrupts -p "${rule_file[0]}"
    fi

}
main "${@}"
