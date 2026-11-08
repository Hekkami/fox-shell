#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

print_info "Installing essential system packages..."
retry_command sudo pacman -S --needed --noconfirm \
  git base-devel tlp \
  chromium \
  hyprland kitty hypridle hyprlock brightnessctl playerctl hyprpolkitagent \
  quickshell \
  yazi ffmpeg 7zip jq poppler resvg imagemagick mpv imv \
  xdg-desktop-portal xdg-desktop-portal-hyprland nwg-look gnome-themes-extra \
  qt5-wayland qt6-wayland \
  gcc make ripgrep fd tree-sitter-cli unzip neovim lazygit \
  wl-clipboard grim slurp cliphist libnotify \
  ttf-jetbrains-mono-nerd \
  xdg-user-dirs udisks2 udiskie xdg-utils \
  bluez bluez-utils networkmanager

print_success "Base packages installed."

print_info "Creating home directories..."
xdg-user-dirs-update
print_success "Home directories created."

print_info "Enabling core system services (TLP, Bluetooth, NetworkManager)..."
# Conflict resolution for TLP
if systemctl is-active --quiet power-profiles-daemon 2>/dev/null || systemctl is-enabled --quiet power-profiles-daemon 2>/dev/null; then
  print_warning "power-profiles-daemon conflicts with tlp; disabling and masking it..."
  sudo systemctl disable --now power-profiles-daemon
  sudo systemctl mask power-profiles-daemon
fi

if sudo systemctl enable --now tlp.service; then
  print_success "TLP enabled."
else
  print_warning "Could not enable TLP. Run 'sudo systemctl enable --now tlp.service' manually."
fi

# Enable Bluetooth and NetworkManager daemons
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now NetworkManager.service
print_success "Bluetooth and NetworkManager services enabled."

print_info "Checking and installing audio stack if missing..."
for pkg in pipewire wireplumber pipewire-pulse pipewire-alsa; do
  if ! pacman -Qs "$pkg" >/dev/null; then
    print_info "Installing $pkg..."
    retry_command sudo pacman -S --needed --noconfirm "$pkg"
  else
    print_info "$pkg is already installed, skipping."
  fi
done
print_success "Audio stack configured."
print_success "Audio stack configured."
