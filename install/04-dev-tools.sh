#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

print_info "Starting Docker and Mise setup..."

if prompt_app_yn "Do you want to install Docker and Docker Compose?" "y"; then
  print_info "Installing Docker..."
  if retry_command sudo pacman -S --needed --noconfirm docker docker-compose docker-buildx; then
    print_success "Docker packages installed via pacman."

    print_info "Enabling and starting Docker service..."
    sudo systemctl enable --now docker.service

    if ! groups | grep -q docker; then
      print_info "Adding current user ($USER) to the docker group..."
      sudo usermod -aG docker "$USER"
      print_success "User added to docker group."
    else
      print_success "User is already in the docker group."
    fi
  else
    print_warning "Failed to install Docker via pacman."
  fi
fi

if prompt_app_yn "Do you want to install Mise?" "y"; then
  print_info "Installing Mise via pacman..."
  if retry_command sudo pacman -S --needed --noconfirm mise; then
    print_success "Mise installed successfully via pacman."
  else
    print_warning "Failed to install Mise via pacman."
  fi
fi

print_success "Dev tools installation completed."
