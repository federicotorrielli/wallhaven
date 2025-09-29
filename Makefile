# Simple Makefile for wallhaven

PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
SERVICEDIR = /etc/systemd/system

# User installation directories
USER_BINDIR = $(HOME)/.local/bin
USER_SERVICEDIR = $(HOME)/.config/systemd/user

.PHONY: all install install-user uninstall uninstall-user clean test

all:
	@echo "wallhaven - KISS wallpaper downloader"
	@echo ""
	@echo "Targets:"
	@echo "  install       Install system-wide (requires root)"
	@echo "  install-user  Install for current user"
	@echo "  uninstall     Uninstall system-wide (requires root)"
	@echo "  uninstall-user Uninstall for current user"
	@echo "  test          Test the script"
	@echo "  clean         Clean cache"

install:
	@if [ `id -u` -ne 0 ]; then \
		echo "Error: System install requires root privileges. Use 'make install-user' or run with sudo."; \
		exit 1; \
	fi
	install -d $(BINDIR)
	install -m 755 wallhaven $(BINDIR)/wallhaven
	@if command -v systemctl >/dev/null 2>&1; then \
		install -d $(SERVICEDIR); \
		install -m 644 wallhaven@.service $(SERVICEDIR)/wallhaven@.service; \
		install -m 644 wallhaven@.timer $(SERVICEDIR)/wallhaven@.timer; \
		systemctl daemon-reload; \
		echo "Systemd services installed. Enable with:"; \
		echo "  systemctl --user enable wallhaven@\$$(whoami).timer"; \
	fi
	@echo "Installed to $(BINDIR)/wallhaven"

install-user:
	install -d $(USER_BINDIR)
	install -m 755 wallhaven $(USER_BINDIR)/wallhaven
	@if command -v systemctl >/dev/null 2>&1; then \
		install -d $(USER_SERVICEDIR); \
		install -m 644 wallhaven@.service $(USER_SERVICEDIR)/wallhaven@.service; \
		install -m 644 wallhaven@.timer $(USER_SERVICEDIR)/wallhaven@.timer; \
		systemctl --user daemon-reload; \
		echo "Systemd services installed. Enable with:"; \
		echo "  systemctl --user enable wallhaven@\$$(whoami).timer"; \
	fi
	@echo "Installed to $(USER_BINDIR)/wallhaven"
	@if ! echo "$(PATH)" | grep -q "$(USER_BINDIR)"; then \
		echo ""; \
		echo "Add $(USER_BINDIR) to your PATH:"; \
		echo "  echo 'export PATH=\"$(USER_BINDIR):\$$PATH\"' >> ~/.bashrc"; \
	fi

uninstall:
	@if [ `id -u` -ne 0 ]; then \
		echo "Error: System uninstall requires root privileges. Use 'make uninstall-user' or run with sudo."; \
		exit 1; \
	fi
	rm -f $(BINDIR)/wallhaven
	@if command -v systemctl >/dev/null 2>&1; then \
		systemctl --user --global disable wallhaven@.timer 2>/dev/null || true; \
		systemctl --user --global stop wallhaven@.timer 2>/dev/null || true; \
		rm -f $(SERVICEDIR)/wallhaven@.service; \
		rm -f $(SERVICEDIR)/wallhaven@.timer; \
		systemctl daemon-reload; \
	fi
	@echo "Uninstalled from $(BINDIR)/wallhaven"

uninstall-user:
	rm -f $(USER_BINDIR)/wallhaven
	@if command -v systemctl >/dev/null 2>&1; then \
		systemctl --user disable wallhaven@$$(whoami).timer 2>/dev/null || true; \
		systemctl --user stop wallhaven@$$(whoami).timer 2>/dev/null || true; \
		rm -f $(USER_SERVICEDIR)/wallhaven@.service; \
		rm -f $(USER_SERVICEDIR)/wallhaven@.timer; \
		systemctl --user daemon-reload; \
	fi
	@echo "Uninstalled from $(USER_BINDIR)/wallhaven"

clean:
	rm -rf ~/.cache/wallhaven/
	@echo "Cache cleaned"

test:
	@if ! ./wallhaven -h >/dev/null 2>&1; then \
		echo "Error: Script test failed"; \
		exit 1; \
	fi
	@echo "Script syntax OK"
	@if command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1; then \
		echo "HTTP client available"; \
	else \
		echo "Warning: No HTTP client found (install curl or wget)"; \
	fi
	@if command -v feh >/dev/null 2>&1 || command -v nitrogen >/dev/null 2>&1 || \
	   command -v xwallpaper >/dev/null 2>&1 || command -v gsettings >/dev/null 2>&1 || \
	   command -v swaybg >/dev/null 2>&1; then \
		echo "Wallpaper setter available"; \
	else \
		echo "Warning: No wallpaper setter found (install feh, nitrogen, xwallpaper, or swaybg)"; \
	fi