#!/bin/sh
# Installer script for wallhaven
# Can be run as regular user (installs to ~/.local) or as root (installs system-wide)

set -e

SCRIPT_DIR="$(dirname "$0")"

# Detect OS
OS_TYPE="$(uname -s)"

# Determine install mode based on user
if [ "$(id -u)" -eq 0 ]; then
    # System-wide installation (root)
    INSTALL_DIR="/usr/local/bin"
    SERVICE_DIR="/etc/systemd/system"
    INSTALL_MODE="system"
    printf "Installing wallhaven system-wide...\n"
else
    # User installation (non-root)
    INSTALL_DIR="${HOME}/.local/bin"
    SERVICE_DIR="${HOME}/.config/systemd/user"
    INSTALL_MODE="user"
    printf "Installing wallhaven for current user...\n"
    
    # Create directories if they don't exist
    mkdir -p "$INSTALL_DIR"
    
    # Add ~/.local/bin to PATH if not already there
    if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
        printf "\nNote: Add ~/.local/bin to your PATH if not already done:\n"
        if [ "$OS_TYPE" = "Darwin" ]; then
            printf "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc\n"
            printf "  # or for bash: echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bash_profile\n"
        else
            printf "  echo 'set -gx PATH ~/.local/bin \$PATH' >> ~/.config/fish/config.fish\n"
            printf "  # or for bash: echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc\n"
        fi
    fi
fi

# Install the script
printf "Installing wallhaven to %s...\n" "$INSTALL_DIR"
cp "$SCRIPT_DIR/wallhaven" "$INSTALL_DIR/wallhaven"
chmod 755 "$INSTALL_DIR/wallhaven"

# Install scheduler (systemd for Linux, launchd for macOS)
if [ "$OS_TYPE" = "Darwin" ]; then
    # macOS - use launchd
    LAUNCHAGENTS_DIR="${HOME}/Library/LaunchAgents"
    mkdir -p "$LAUNCHAGENTS_DIR"
    
    printf "Installing launchd service for automatic wallpaper changes...\n"
    
    # Check if plist file exists
    if [ ! -f "$SCRIPT_DIR/com.wallhaven.plist" ]; then
        printf "Error: com.wallhaven.plist not found in %s\n" "$SCRIPT_DIR" >&2
        exit 1
    fi
    
    # Copy and update the plist file
    cp "$SCRIPT_DIR/com.wallhaven.plist" "$LAUNCHAGENTS_DIR/com.wallhaven.plist"
    
    # Update the path in the plist if using non-standard install location
    if [ "$INSTALL_DIR" != "/usr/local/bin" ]; then
        sed -i '' "s|/usr/local/bin/wallhaven|$INSTALL_DIR/wallhaven|g" "$LAUNCHAGENTS_DIR/com.wallhaven.plist"
    fi
    
    # Load the service
    launchctl load "$LAUNCHAGENTS_DIR/com.wallhaven.plist" 2>/dev/null || true
    
    printf "Installation complete!\n\n"
    printf "Wallpaper will change automatically every hour.\n\n"
    printf "To manually change wallpaper once:\n"
    printf "  wallhaven\n\n"
    printf "To stop automatic changes:\n"
    printf "  launchctl unload %s/com.wallhaven.plist\n\n" "$LAUNCHAGENTS_DIR"
    printf "To start automatic changes again:\n"
    printf "  launchctl load %s/com.wallhaven.plist\n\n" "$LAUNCHAGENTS_DIR"
    
elif command -v systemctl >/dev/null 2>&1; then
    # Linux - use systemd
    mkdir -p "$SERVICE_DIR"
    printf "Installing systemd service and timer...\n"
    
    if [ "$INSTALL_MODE" = "system" ]; then
        # System-wide installation - use template service with User=%i
        cp "$SCRIPT_DIR/wallhaven@.service" "$SERVICE_DIR/wallhaven@.service"
        cp "$SCRIPT_DIR/wallhaven@.timer" "$SERVICE_DIR/wallhaven@.timer"
        systemctl daemon-reload
        printf "Installation complete!\n\n"
        printf "For any user to enable automatic wallpaper changes:\n"
        printf "  systemctl --user enable wallhaven@\$(whoami).timer\n"
        printf "  systemctl --user start wallhaven@\$(whoami).timer\n\n"
        printf "To change wallpaper once:\n"
        printf "  systemctl --user start wallhaven@\$(whoami).service\n\n"
    else
        # User installation - create service without User= and with correct path
        sed "s|/usr/local/bin/wallhaven|$INSTALL_DIR/wallhaven|g; /^User=/d" \
            "$SCRIPT_DIR/wallhaven@.service" > "$SERVICE_DIR/wallhaven@.service"
        
        # Update timer to reference the correct service
        sed "s|wallhaven@%i.service|wallhaven@$(whoami).service|g" \
            "$SCRIPT_DIR/wallhaven@.timer" > "$SERVICE_DIR/wallhaven@.timer"
        
        systemctl --user daemon-reload
        printf "Installation complete!\n\n"
        printf "To enable automatic wallpaper changes every hour:\n"
        printf "  systemctl --user enable wallhaven@%s.timer\n" "$(whoami)"
        printf "  systemctl --user start wallhaven@%s.timer\n\n" "$(whoami)"
        printf "To change wallpaper once:\n"
        printf "  systemctl --user start wallhaven@%s.service\n\n" "$(whoami)"
    fi
else
    printf "Systemd not found, skipping service installation\n\n"
fi

printf "You can now use 'wallhaven' from the command line!\n"
printf "Run 'wallhaven -h' for help\n\n"

# Show quick usage examples
printf "Quick examples:\n"
printf "  wallhaven                    # Random wallpaper\n"
printf "  wallhaven nature landscape   # Search for nature/landscape\n"
printf "  wallhaven -s toplist         # Top-rated wallpapers\n"
printf "  wallhaven -r 1920x1080      # HD wallpapers only\n"