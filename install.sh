#!/usr/bin/env bash

# Installation script for lugo command system
# Supports macOS and Linux

set -e

# Configuration
INSTALL_DIR="${HOME}/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_URL="https://github.com/CarlosLugones/scripts"
TEMP_DIR="/tmp/lugo-install-$$"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if directory is in PATH
check_path() {
    if [[ ":$PATH:" == *":$1:"* ]]; then
        return 0
    else
        return 1
    fi
}

# Check if curl is available
check_curl() {
    if ! command -v curl >/dev/null 2>&1; then
        print_error "curl is not installed or not in PATH"
        print_error "Please install curl to use remote installation"
        exit 1
    fi
}

# Check if we need to download files (remote installation)
needs_remote_download() {
    [[ ! -f "$SCRIPT_DIR/lugo" ]] || [[ ! -d "$SCRIPT_DIR/commands" ]]
}

# Download required files from GitHub
download_files() {
    print_status "Detected remote installation, downloading files from GitHub..."
    
    check_curl
    
    # Create temporary directory
    mkdir -p "$TEMP_DIR"
    
    # Download main lugo script
    print_status "Downloading lugo command..."
    if ! curl -sSL -f "$REPO_URL/raw/main/lugo" -o "$TEMP_DIR/lugo"; then
        print_error "Failed to download lugo script"
        cleanup_temp
        exit 1
    fi
    chmod +x "$TEMP_DIR/lugo"
    
    # Download VERSION file
    print_status "Downloading VERSION file..."
    if ! curl -sSL -f "$REPO_URL/raw/main/VERSION" -o "$TEMP_DIR/VERSION"; then
        print_warning "Failed to download VERSION file, continuing without it"
    fi
    
    # Create commands directory and download command scripts
    print_status "Downloading command scripts..."
    mkdir -p "$TEMP_DIR/commands"
    
    # List of available commands (should match AVAILABLE_COMMANDS in lugo script)
    local commands=("dlvid" "duplicates" "renameseq" "update")
    
    for cmd in "${commands[@]}"; do
        if ! curl -sSL -f "$REPO_URL/raw/main/commands/$cmd" -o "$TEMP_DIR/commands/$cmd"; then
            print_error "Failed to download command: $cmd"
            cleanup_temp
            exit 1
        fi
        chmod +x "$TEMP_DIR/commands/$cmd"
    done
    
    # Update SCRIPT_DIR to point to temp directory
    SCRIPT_DIR="$TEMP_DIR"
    print_status "Files downloaded successfully"
}

# Cleanup temporary files
cleanup_temp() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Main installation function
install_lugo() {
    print_status "Installing lugo command system..."

    # Check if we need to download files (remote installation)
    if needs_remote_download; then
        download_files
        # Set up cleanup trap for temp files
        trap cleanup_temp EXIT
    fi

    # Create install directory if it doesn't exist
    if [[ ! -d "$INSTALL_DIR" ]]; then
        print_status "Creating install directory: $INSTALL_DIR"
        mkdir -p "$INSTALL_DIR"
    fi

    # Copy main lugo script
    print_status "Installing lugo main command..."
    cp "$SCRIPT_DIR/lugo" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/lugo"

    # Copy VERSION file
    if [[ -f "$SCRIPT_DIR/VERSION" ]]; then
        cp "$SCRIPT_DIR/VERSION" "$INSTALL_DIR/"
        print_status "Installed VERSION file"
    fi

    # Copy commands directory
    print_status "Installing command scripts..."
    if [[ -d "$INSTALL_DIR/commands" ]]; then
        rm -rf "$INSTALL_DIR/commands"
    fi
    cp -r "$SCRIPT_DIR/commands" "$INSTALL_DIR/"

    # Update the lugo script to use the installed commands directory and VERSION file
    sed -i.bak \
        -e "s|COMMANDS_DIR=\"\${SCRIPT_DIR}/commands\"|COMMANDS_DIR=\"$INSTALL_DIR/commands\"|" \
        -e "s|VERSION_FILE=\"\${SCRIPT_DIR}/VERSION\"|VERSION_FILE=\"$INSTALL_DIR/VERSION\"|" \
        "$INSTALL_DIR/lugo"
    rm "$INSTALL_DIR/lugo.bak" 2>/dev/null || true

    # Create individual command symlinks for direct access
    print_status "Creating individual command symlinks..."
    for cmd in dlvid duplicates renameseq update; do
        if [[ -f "$INSTALL_DIR/$cmd" ]]; then
            rm "$INSTALL_DIR/$cmd"
        fi
        ln -s "$INSTALL_DIR/commands/$cmd" "$INSTALL_DIR/$cmd"
    done

    print_status "Installation complete!"

    # Check PATH
    if ! check_path "$INSTALL_DIR"; then
        print_warning "Warning: $INSTALL_DIR is not in your PATH"
        print_warning "Add the following line to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
        echo "export PATH=\"\$PATH:$INSTALL_DIR\""
        echo ""
        print_warning "Or run: echo 'export PATH=\"\$PATH:$INSTALL_DIR\"' >> ~/.bashrc"
        print_warning "Then restart your shell or run: source ~/.bashrc"
    else
        print_status "$INSTALL_DIR is already in your PATH"
    fi

    echo ""
    print_status "You can now use:"
    echo "  lugo --help          # Show main help"
    echo "  lugo --version       # Show version"
    echo "  lugo dlvid --help    # Show dlvid help"
    echo "  lugo update          # Update to latest version"
    echo "  dlvid --help         # Direct command access"
    echo "  duplicates --help    # Direct command access"
    echo "  renameseq --help     # Direct command access"
    echo "  update --help        # Direct command access"
}

# Uninstall function
uninstall_lugo() {
    print_status "Uninstalling lugo command system..."
    
    # Remove main script
    if [[ -f "$INSTALL_DIR/lugo" ]]; then
        rm "$INSTALL_DIR/lugo"
        print_status "Removed lugo main command"
    fi
    
    # Remove VERSION file
    if [[ -f "$INSTALL_DIR/VERSION" ]]; then
        rm "$INSTALL_DIR/VERSION"
        print_status "Removed VERSION file"
    fi
    
    # Remove commands directory
    if [[ -d "$INSTALL_DIR/commands" ]]; then
        rm -rf "$INSTALL_DIR/commands"
        print_status "Removed commands directory"
    fi
    
    # Remove individual command symlinks
    for cmd in dlvid duplicates renameseq update; do
        if [[ -L "$INSTALL_DIR/$cmd" ]]; then
            rm "$INSTALL_DIR/$cmd"
            print_status "Removed $cmd symlink"
        fi
    done
    
    print_status "Uninstallation complete!"
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [install|uninstall]

Commands:
    install      Install lugo command system (default)
    uninstall    Remove lugo command system

Options:
    --help       Show this help message

The lugo command system will be installed to: $INSTALL_DIR
EOF
}

# Main script logic
main() {
    case "${1:-install}" in
        install)
            install_lugo
            ;;
        uninstall)
            uninstall_lugo
            ;;
        --help|-h)
            show_usage
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"