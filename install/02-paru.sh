#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

print_info "Checking AUR helper (paru)..."

if command -v paru &>/dev/null; then
  print_success "Paru is already installed. Skipping installation."
elif retry_command sudo pacman -S --needed --noconfirm paru; then
  print_success "Paru installed via pacman."
else
  print_info "Paru not available via pacman. Building it from the AUR instead..."

  retry_command sudo pacman -S --needed --noconfirm base-devel git

  if retry_command bash -c 'rm -rf /tmp/paru && git clone https://aur.archlinux.org/paru.git /tmp/paru'; then
    trap 'rm -rf /tmp/paru' EXIT
    (cd /tmp/paru && retry_command makepkg -si --noconfirm)
    print_success "Paru installed successfully."
  else
    print_error "Failed to clone paru repository."
    rm -rf /tmp/paru
    exit 1
  fi
fi
