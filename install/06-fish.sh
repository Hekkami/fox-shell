#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

print_info "Configuring Shell environment (Fish)..."

fish_path="$(command -v fish)"
current_shell="$(getent passwd "$USER" | cut -d: -f7)"

if [ "$current_shell" != "$fish_path" ]; then
  print_info "Setting fish as the default shell for $USER..."
  if sudo usermod -s "$fish_path" "$USER"; then
    print_success "Default shell set to fish. (Takes effect on next login)."
  else
    print_warning "Could not set fish automatically. Run 'chsh -s $fish_path' manually."
  fi
else
  print_info "Fish is already the default shell."
fi

print_success "Shell configuration completed."
