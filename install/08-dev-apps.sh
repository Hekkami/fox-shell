#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

print_info "Starting interactive developer applications installation..."

pacman_apps=(
  "dbeaver:Universal database tool and SQL client for developers and administrators"
  "code:Free and open-source code editor developed by Microsoft (Code-OSS)"
  "cursor-bin:The AI-first code editor built for programming with AI assistance"
  "godot:Free and open-source 2D and 3D game engine"
)
install_pacman_apps pacman_apps

aur_apps=(
  "antigravity-ide:An agentic development platform from Google, evolving the IDE into the agent-first era"
  "beekeeper-studio-bin:Modern and easy-to-use SQL GUI client and database manager"
  "mongodb-compass-bin:The official GUI for MongoDB database management"
  "bruno-bin:Fast and git-friendly open-source API client"
  "postman-bin:API platform for building and testing APIs"
)
install_aur_apps aur_apps

print_success "Developer applications installation completed."
