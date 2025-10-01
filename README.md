# wallhaven

A KISS suckless-style script for downloading and setting wallpapers from [Wallhaven](https://wallhaven.cc/) using their API.

## Features

- **Simple**: Single shell script, no dependencies except curl/wget
- **Fast**: Direct API access, minimal parsing
- **Flexible**: Search by tags, categories, resolution, aspect ratio
- **Random selection**: Pick random wallpaper from search results, not just the first
- **Automatic**: Can be scheduled to change wallpapers periodically
- **Cross-platform**: Works with various wallpaper setters (feh, nitrogen, gsettings, xwallpaper, swaybg)
- **GNOME compatible**: Sets wallpaper for both light and dark modes in GNOME
- **Caching**: Downloads are cached to avoid re-downloading

## Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/federicotorrielli/wallhaven.git
cd wallhaven

# Install (run as user for local install, or with sudo for system-wide)
./install.sh

# Or install system-wide
sudo ./install.sh
```

### Manual Install

```bash
# Copy script to your PATH
cp wallhaven ~/.local/bin/
chmod +x ~/.local/bin/wallhaven

# Make sure ~/.local/bin is in your PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  # for bash
echo 'set -gx PATH ~/.local/bin $PATH' >> ~/.config/fish/config.fish  # for fish
```

## Dependencies

**Required** (one of):

- `curl` or `wget` for API requests and downloads

**Wallpaper Setters** (one of):

- `feh` (recommended for X11)
- `nitrogen`
- `xwallpaper`
- `swaybg` (for Wayland/Sway)
- `gsettings` (for GNOME)

## Usage

### Basic Usage

```bash
wallhaven                           # Random SFW wallpaper
wallhaven nature landscape          # Search for nature/landscape wallpapers
wallhaven -s toplist               # Top-rated wallpapers (picks first result)
wallhaven -s toplist -x            # Random wallpaper from top-rated results
wallhaven -s toplist -t 1M         # Top wallpapers from last month
wallhaven -r 1920x1080             # HD wallpapers minimum
wallhaven -e 1920x1080,2560x1440   # Exact resolutions only
wallhaven -R 16x9                  # 16:9 aspect ratio only
wallhaven -C 660000                # Search by red color
wallhaven -c 010 anime             # Anime category only
wallhaven -d sunset                # Download only, don't set
wallhaven -P 2 nature              # Page 2 of nature results
```

### Advanced Usage

```bash
# Combine multiple filters
wallhaven -r 2560x1440 -R 16x9 -s toplist landscape
wallhaven -e 1920x1080 -C 660000 -x  # Exact resolution with red color

# Time-based top lists
wallhaven -s toplist -t 1d -x      # Top wallpapers from last day
wallhaven -s toplist -t 1w nature  # Top nature wallpapers from last week
wallhaven -s toplist -t 1M -x      # Random from last month's top wallpapers

# Sorting and ordering
wallhaven -s date_added -o asc     # Oldest wallpapers first
wallhaven -s views -o desc         # Most viewed wallpapers

# Pagination for browsing
wallhaven -P 1 landscape           # First page
wallhaven -P 2 landscape           # Second page
wallhaven -P 3 landscape           # Third page

# Random selection with consistent results using seed
wallhaven -s random -S abc123      # Use seed for reproducible random results

# Color-based searches
wallhaven -C 660000 -x             # Red-toned wallpapers
wallhaven -C 0066cc -x             # Blue-toned wallpapers
wallhaven -C 336600 -x             # Green-toned wallpapers

# Random selection from specific results
wallhaven -s toplist -x nature     # Random from top nature wallpapers
wallhaven -s favorites -x anime    # Random from favorite anime wallpapers
wallhaven -c 010 -x -s views       # Random from most-viewed anime wallpapers

# Use tags and operators
wallhaven "+landscape -people"     # Must have landscape, no people
wallhaven "@username"              # Wallpapers by specific user
wallhaven "id:123"                 # Exact tag ID search
wallhaven "type:png"               # PNG files only
wallhaven "like:94x38z"           # Similar to wallpaper ID 94x38z

# With API key for NSFW content
wallhaven -k your_api_key -p 111 anime
```

### Options

```bash
-h              Show help
-c CATEGORIES   Categories (100=general, 010=anime, 001=people, 111=all)
-p PURITY       Purity (100=SFW, 110=SFW+sketchy, 111=all, requires API key)
-s SORTING      Sorting (random, date_added, views, favorites, toplist)
-o ORDER        Sorting order (desc, asc)
-t TOPRANGE     Top range (1d, 3d, 1w, 1M, 3M, 6M, 1y) - requires -s toplist
-r RESOLUTION   Minimum resolution (e.g., 1920x1080)
-e RESOLUTIONS  Exact resolutions (e.g., 1920x1080,1920x1200)
-R RATIOS       Aspect ratios (e.g., 16x9,16x10)
-C COLORS       Search by color (hex without #, e.g., 660000)
-P PAGE         Page number for pagination (default: 1)
-S SEED         Seed for random results (6 alphanumeric chars)
-k API_KEY      API key for authenticated requests
-x              Pick random wallpaper from search results (not just first)
-d              Download only, don't set wallpaper
-l              List downloaded wallpapers
-X              Clean cache (remove all downloaded wallpapers)
```

## Automatic Wallpaper Changes

The installer sets up systemd services for automatic wallpaper changes.

### Enable Hourly Wallpaper Changes

```bash
# Enable the timer (starts automatically at boot)
systemctl --user enable wallhaven@$(whoami).timer
systemctl --user start wallhaven@$(whoami).timer

# Check status
systemctl --user status wallhaven@$(whoami).timer
```

### Manual Wallpaper Change

```bash
# Change wallpaper once
systemctl --user start wallhaven@$(whoami).service

# Or just run the script directly
wallhaven
```

### Custom Schedule

Edit the timer file to change the schedule:

```bash
# Edit timer (user install)
systemctl --user edit wallhaven@$(whoami).timer

# Add custom schedule, e.g., every 30 minutes:
[Timer]
OnCalendar=*:0/30
```

## Configuration

### API Key (Optional)

Get your API key from [Wallhaven Settings](https://wallhaven.cc/settings/account) to access NSFW content and higher rate limits.

Edit the script and set:

```bash
API_KEY="your_api_key_here"
```

Or use the `-k` option:

```bash
wallhaven -k your_api_key -p 111 anime
```

### Default Settings

Edit these variables in the script to change defaults:

```bash
CATEGORIES="111"    # 111=all, 100=general, 010=anime, 001=people
PURITY="100"        # 100=SFW, 110=SFW+sketchy, 111=all (needs API key)
SORTING="random"    # random, date_added, views, favorites, toplist
ORDER=""            # desc (default), asc
TOPRANGE=""         # 1d, 3d, 1w, 1M, 3M, 6M, 1y (requires sorting=toplist)
ATLEAST=""          # minimum resolution, e.g., "1920x1080"
RESOLUTIONS=""      # exact resolutions, e.g., "1920x1080,1920x1200"
RATIOS=""           # aspect ratios, e.g., "16x9,16x10"
COLORS=""           # color search, e.g., "660000" (hex without #)
PAGE=""             # page number for pagination (default: 1)
SEED=""             # seed for consistent random results (6 alphanumeric chars)
```

## File Locations

- **Script**: `~/.local/bin/wallhaven` (user) or `/usr/local/bin/wallhaven` (system)
- **Cache**: `~/.cache/wallhaven/`
- **Current wallpaper**: `~/.cache/wallhaven/current`
- **Systemd files**: `~/.config/systemd/user/` (user) or `/etc/systemd/system/` (system)

## Examples

### Daily Routine

```bash
# Morning: inspirational landscape
wallhaven -s toplist landscape mountains

# Work: minimal/abstract
wallhaven minimal abstract -c 100

# Evening: cozy/warm colors
wallhaven cozy warm -s favorites
```

### Different Monitor Setups

```bash
# 4K monitor - exact resolution
wallhaven -e 3840x2160 -s toplist -x

# 4K monitor - minimum resolution
wallhaven -r 3840x2160 -s toplist

# Ultrawide monitor
wallhaven -R 21x9 landscape

# Multiple common resolutions
wallhaven -e 1920x1080,2560x1440,3840x2160 -x

# Dual monitor (run twice with different searches)
wallhaven -d nature && wallhaven -d space
```

## Troubleshooting

### No wallpaper setter found

Install one of the supported wallpaper setters:

```bash
# Ubuntu/Debian
sudo apt install feh

# Arch Linux
sudo pacman -S feh

# Fedora
sudo dnf install feh
```

### API errors

- Check your internet connection
- Verify API key if using NSFW content
- Check rate limits (45 requests per minute)

### Systemd service not working

```bash
# Check service status
systemctl --user status wallhaven@$(whoami).service

# Check logs
journalctl --user -u wallhaven@$(whoami).service

# Test manually
wallhaven -d test  # Download only to test API
```

## API Reference

This script uses the Wallhaven API v1. For detailed API documentation, visit:
https://wallhaven.cc/help/api

### Rate Limits

- 45 requests per minute for guests
- Higher limits with API key

### Search Parameters

- **Categories**: 1=on, 0=off for [general, anime, people]
- **Purity**: 1=on, 0=off for [SFW, sketchy, NSFW]
- **Sorting**: random, date_added, views, favorites, toplist, relevance
- **Order**: desc (default), asc
- **Top Range**: 1d, 3d, 1w, 1M (default), 3M, 6M, 1y (requires toplist sorting)
- **At Least**: Minimum resolution (e.g., 1920x1080)
- **Resolutions**: Exact resolutions (e.g., 1920x1080,1920x1200)
- **Ratios**: Aspect ratios (e.g., 16x9,16x10,21x9)
- **Colors**: Hex color code without # (e.g., 660000 for red)
- **Page**: Page number for pagination (24 results per page)
- **Seed**: 6 alphanumeric characters for reproducible random results

## License

This project is licensed under the European Union Public Licence v. 1.2 (EUPL-1.2).
See the [LICENSE](LICENSE) file for details.

## Contributing

This is a suckless-style project. Keep it simple:

- No dependencies beyond basic UNIX tools
- Shell script only (POSIX sh compatible)
- Minimal features, maximum utility
- Clear, readable code

Submit issues and pull requests on the repository.
