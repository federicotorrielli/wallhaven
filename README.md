# wallhaven

Download and set wallpapers from wallhaven.cc

## Installation

    make install-user        # ~/.local/bin + user systemd units (no root)
    sudo make install        # system-wide to /usr/local/bin (Linux)
    make install-launchd     # macOS: install + load the hourly launchd agent

Or manually:

    cp wallhaven ~/.local/bin/
    chmod +x ~/.local/bin/wallhaven

## Usage

    wallhaven                           # random wallpaper
    wallhaven nature landscape          # search terms
    wallhaven -r 1920x1080              # minimum resolution
    wallhaven -c 010                    # anime category only
    wallhaven -s toplist -x             # random from top-rated
    wallhaven -s toplist -t 1M -x -n 5  # random from top 120 (5 pages)
    wallhaven -d sunset                 # download only
    wallhaven -V                        # visual selection with wallrs

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
    -n NUM_PAGES    pages to fetch for -x random pool (default: 1)
    -x              random from results (not just first)
    -d              download only, don't set
    -V              visual selection mode (requires wallrs)
    -l              list downloaded wallpapers
    -X              clean cache

## Configuration

Copy `config.example` to `~/.config/wallhaven/config` — it is automatically sourced on startup. CLI flags override config values.

    cp config.example ~/.config/wallhaven/config

Key settings:

    CATEGORIES="111"    # 111=all, 100=general, 010=anime, 001=people
    PURITY="100"        # 100=SFW, 110=SFW+sketchy, 111=all
    SORTING="random"    # random, date_added, views, favorites, toplist
    TOPRANGE="1M"       # requires SORTING=toplist
    ATLEAST="1920x1080" # minimum resolution
    RATIOS="16x9"       # aspect ratio filter
    NUM_PAGES=1         # pages to pool for random selection
    RANDOM_SELECT=1     # always pick randomly (equivalent to -x)
    API_KEY=""          # for NSFW content and higher rate limits

An API key can be obtained at https://wallhaven.cc/settings/account.

Cache is stored in `~/.cache/wallhaven/`.

## Automatic Changes

### Linux (systemd)

Enable systemd timer:

    systemctl --user enable --now wallhaven@$(whoami).timer

### macOS (launchd)

Install the launch agent:

    make install-launchd

Or manually:

    sed "s|/usr/local/bin|$HOME/.local/bin|" com.wallhaven.plist > ~/Library/LaunchAgents/com.wallhaven.plist
    launchctl load ~/Library/LaunchAgents/com.wallhaven.plist

To uninstall:

    launchctl unload ~/Library/LaunchAgents/com.wallhaven.plist
    rm ~/Library/LaunchAgents/com.wallhaven.plist

## License

EUPL-1.2
