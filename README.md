# wallhaven

Download and set wallpapers from wallhaven.cc

## Installation

### macOS

    ./install.sh

This will install to `~/.local/bin/wallhaven` and set up automatic wallpaper changes via launchd.

### Linux

    ./install.sh

Or manually:

    cp wallhaven ~/.local/bin/
    chmod +x ~/.local/bin/wallhaven

## Usage

    wallhaven                    # random wallpaper
    wallhaven nature landscape   # search terms
    wallhaven -r 1920x1080       # minimum resolution
    wallhaven -c 010 anime       # anime category only
    wallhaven -s toplist -x      # random from top-rated
    wallhaven -d sunset          # download only
    wallhaven -V                 # visual selection with wallrs

Options:

    -h              help
    -c CATEGORIES   100=general, 010=anime, 001=people, 111=all
    -p PURITY       100=SFW, 110=SFW+sketchy, 111=all (needs API key)
    -s SORTING      random, date_added, views, favorites, toplist
    -o ORDER        desc, asc
    -t TOPRANGE     1d, 3d, 1w, 1M, 3M, 6M, 1y (requires -s toplist)
    -r RESOLUTION   minimum resolution (1920x1080)
    -e RESOLUTIONS  exact resolutions (1920x1080,2560x1440)
    -R RATIOS       aspect ratios (16x9,16x10)
    -C COLORS       hex color without # (660000)
    -P PAGE         page number (default: 1)
    -S SEED         6 alphanumeric chars for reproducible random
    -k API_KEY      API key for authenticated requests
    -x              random from results (not just first)
    -d              download only, don't set
    -V              visual selection mode (requires wallrs)
    -l              list downloaded wallpapers
    -X              clean cache

## Automatic Changes

### Linux (systemd)

Enable systemd timer:

    systemctl --user enable --now wallhaven@$(whoami).timer

### macOS (launchd)

Install the launch agent:

    make install-launchd

Or manually:

    cp com.wallhaven.plist ~/Library/LaunchAgents/
    launchctl load ~/Library/LaunchAgents/com.wallhaven.plist

To uninstall:

    launchctl unload ~/Library/LaunchAgents/com.wallhaven.plist
    rm ~/Library/LaunchAgents/com.wallhaven.plist

## Configuration

Edit the script to set API key and defaults. Cache: ~/.cache/wallhaven/

## License

EUPL-1.2
