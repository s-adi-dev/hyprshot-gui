#!/usr/bin/env bash

# Hyprshot GUI Installer - Simplified and maintainable version
# Exit on any error
set -euo pipefail

# Configuration
readonly BASE_URL="https://raw.githubusercontent.com"
readonly HYPRSHOT_URL="${BASE_URL}/gustash/hyprshot/refs/heads/main/hyprshot"
readonly HGUI_BASE="${BASE_URL}/s-adi-dev/hyprshot-gui/refs/heads/main/src"
readonly HGUI_EXEC_URL="${HGUI_BASE}/hyprshot-gui"
readonly HGUI_DESKTOP_URL="${HGUI_BASE}/hyprshot.desktop"

readonly INSTALL_DIR="/usr/bin"
readonly DESKTOP_DIR="/usr/share/applications"
readonly CONFIG_FILE="${HOME}/.config/hypr/hyprshot.conf"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running as root
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
}

# Detect privilege escalation command
detect_privup() {
    if command -v doas >/dev/null 2>&1; then
        echo "doas"
    elif command -v sudo >/dev/null 2>&1; then
        echo "sudo"
    else
        log_error "Neither doas nor sudo found. Please install one of them."
        exit 1
    fi
}

# Detect distribution
detect_distro() {
    local os_release_file="/etc/os-release"
    [[ ! -f "$os_release_file" ]] && os_release_file="/usr/lib/os-release"
    
    if [[ -f "$os_release_file" ]]; then
        grep -E "^ID=" "$os_release_file" | cut -d'=' -f2 | tr -d '"'
    else
        log_error "Cannot detect distribution"
        exit 1
    fi
}

# Install dependencies based on distribution
install_dependencies() {
    local distro="$1"
    local privup="$2"
    
    log_info "Installing dependencies for $distro..."
    
    case "$distro" in
        arch|cachyos|manjaro|endeavouros)
            $privup pacman -S --needed --noconfirm git gtk4 python-gobject curl
            ;;
        fedora|nobara)
            $privup dnf install -y git gtk4 python3-gobject curl
            ;;
        opensuse*|suse)
            $privup zypper install -y git gtk4-devel python3-gobject curl
            ;;
        ubuntu|debian|mint|pop|linuxmint)
            $privup apt update && $privup apt install -y git libgtk-4-1 python3-gi curl
            ;;
        *)
            log_warn "Unsupported distribution: $distro"
            log_warn "Please install manually: git, gtk4, python3-gobject, curl"
            read -p "Continue anyway? [y/N] " -n 1 -r
            echo
            [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
            ;;
    esac
}

# Download file with error handling
download_file() {
    local url="$1"
    local output="$2"
    local name="$3"
    
    log_info "Downloading $name..."
    if ! curl -fsSL --progress-bar "$url" -o "$output"; then
        log_error "Failed to download $name from $url"
        exit 1
    fi
}

# Install files
install_files() {
    local privup="$1"
    local temp_dir="$2"
    
    # Install hyprshot
    log_info "Installing hyprshot..."
    $privup install -m 755 "$temp_dir/hyprshot" "$INSTALL_DIR/hyprshot"
    
    # Install hyprshot-gui
    log_info "Installing hyprshot-gui..."
    $privup install -m 755 "$temp_dir/hyprshot-gui" "$INSTALL_DIR/hyprshot-gui"
    
    # Install desktop file
    log_info "Installing desktop file..."
    $privup mkdir -p "$DESKTOP_DIR"
    $privup cp "$temp_dir/hyprshot.desktop" "$DESKTOP_DIR/hyprshot.desktop"
}

# Create default configuration
create_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        log_info "Configuration file already exists: $CONFIG_FILE"
        return
    fi
    
    log_info "Creating default configuration..."
    mkdir -p "$(dirname "$CONFIG_FILE")"
    
    cat > "$CONFIG_FILE" << 'EOF'
[Settings]
OutputDir = ${XDG_PICTURES_DIR:-$HOME/Pictures}
Delay = 0
NotifyTimeout = 5000
ClipboardOnly = False
Silent = False
EOF
}

# Add Hyprland window rule
add_window_rule() {
    local hypr_config_dir="${HOME}/.config/hypr"
    local config_files=()
    
    # Find config files with window rules
    if [[ -d "$hypr_config_dir" ]]; then
        while IFS= read -r -d '' file; do
            config_files+=("$file")
        done < <(find "$hypr_config_dir" -name "*.conf" -type f -exec grep -l "windowrule" {} \; -print0 2>/dev/null)
    fi
    
    local rule="windowrulev2 = float, title:^(.*Hyprshot.*)$"
    local comment="# HyprShot GUI floating rule"
    
    if [[ ${#config_files[@]} -eq 0 ]]; then
        log_warn "No Hyprland config files found with window rules"
        log_info "Please add this rule to your Hyprland config:"
        echo -e "\n$comment\n$rule\n"
        return
    fi
    
    if [[ ${#config_files[@]} -gt 1 ]]; then
        log_warn "Multiple config files found with window rules:"
        printf '%s\n' "${config_files[@]}"
        log_info "Please add this rule manually to the appropriate file:"
        echo -e "\n$comment\n$rule\n"
        return
    fi
    
    local config_file="${config_files[0]}"
    
    # Check if rule already exists
    if grep -Fq "$rule" "$config_file"; then
        log_info "Window rule already exists in $config_file"
        return
    fi
    
    # Backup and add rule
    log_info "Adding window rule to $config_file"
    cp "$config_file" "${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "\n$comment\n$rule" >> "$config_file"
}

# Cleanup function
cleanup() {
    if [[ -n "${temp_dir:-}" ]] && [[ -d "$temp_dir" ]]; then
        rm -rf "$temp_dir"
    fi
}

# Main installation function
main() {
    log_info "Starting Hyprshot GUI installation..."
    
    # Setup cleanup trap
    trap cleanup EXIT
    
    # Pre-flight checks
    check_not_root
    
    # Detect system
    local privup distro temp_dir
    privup=$(detect_privup)
    distro=$(detect_distro)
    temp_dir=$(mktemp -d -t hyprshot-gui-XXXXXX)
    
    log_info "Detected distribution: $distro"
    log_info "Using privilege escalation: $privup"
    
    # Install dependencies
    install_dependencies "$distro" "$privup"
    
    # Download files
    download_file "$HYPRSHOT_URL" "$temp_dir/hyprshot" "hyprshot"
    download_file "$HGUI_EXEC_URL" "$temp_dir/hyprshot-gui" "hyprshot-gui"
    download_file "$HGUI_DESKTOP_URL" "$temp_dir/hyprshot.desktop" "desktop file"
    
    # Make executables
    chmod +x "$temp_dir/hyprshot" "$temp_dir/hyprshot-gui"
    
    # Install files
    install_files "$privup" "$temp_dir"
    
    # Create configuration
    create_config
    
    # Add window rule
    add_window_rule
    
    log_info "Installation completed successfully!"
    log_info "You can now run 'hyprshot-gui' or find it in your applications menu"
    
    # Check if in PATH
    if ! command -v hyprshot-gui >/dev/null 2>&1; then
        log_warn "hyprshot-gui not found in PATH. You may need to restart your session."
    fi
}

# Run main function with all arguments
main "$@"
