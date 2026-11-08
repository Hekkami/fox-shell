#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

print_info "Configuring SDDM display manager..."
retry_command sudo pacman -S --needed --noconfirm sddm

theme_pkg="sddm-silent-theme"

if command -v paru &>/dev/null; then
  print_info "Installing sddm-silent-theme from AUR..."

  theme_cmd=(paru -S --needed --noconfirm "$theme_pkg")

  if pacman -Qq "$theme_pkg" &>/dev/null && ! pacman_app_healthy "$theme_pkg"; then
    print_warning "$theme_pkg is installed but some files are missing or corrupted; reinstalling..."
    theme_cmd=(paru -S --noconfirm "$theme_pkg")
  fi

  if retry_command "${theme_cmd[@]}"; then
    print_success "sddm-silent-theme installed."
  else
    print_warning "sddm-silent-theme failed to install. SDDM will use its default theme instead."
  fi
else
  print_warning "Paru is not installed. Cannot install sddm-silent-theme automatically."
fi

print_info "Ensuring SDDM configuration directory exists..."
sudo mkdir -p /etc/sddm.conf.d

if pacman -Qq "$theme_pkg" &>/dev/null; then
  print_info "Linking fox-shell.conf to SDDM system configuration..."
  sudo ln -sf "$FOX_CORE/sddm/fox-shell.conf" /etc/sddm.conf.d/fox-shell.conf
else
  print_warning "sddm-silent-theme isn't installed; skipping fox-shell.conf so SDDM falls back to its built-in default theme."
fi

print_info "Enabling SDDM service..."
sudo systemctl enable --force sddm.service
print_success "SDDM configured and enabled."
