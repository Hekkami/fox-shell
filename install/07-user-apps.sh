#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

print_info "Starting interactive user applications installation..."

pacman_apps=(
  "obs-studio:Free and open-source software for video recording and live streaming"
  "brave-bin:Privacy-oriented web browser that blocks trackers by default"
  "bitwarden:Secure and free password manager for all of your devices"
  "solaar:Linux device manager for Logitech devices connected via USB or Bluetooth receiver"
)

install_pacman_apps pacman_apps

aur_apps=(
  "feishin:Modern self-hosted music player compatible with Subsonic APIs"
  "spotify:Digital music service providing access to millions of songs"
  "slack-desktop:Channel-based messaging platform for team collaboration"
  "zoom:Video conferencing and web conferencing software"
)
install_aur_apps aur_apps

print_success "User applications installation completed."
