#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

print_info "Configuring Git..."

GIT_LOCAL="$FOX_CORE/git/git-user"
if [ ! -f "$GIT_LOCAL" ]; then
  print_info "Setting up local Git configuration..."
  read -p "Enter your Git name: " git_name
  read -p "Enter your Git email: " git_email
  echo -e "[user]\n    name = $git_name\n    email = $git_email" >"$GIT_LOCAL"
  print_success "Created local Git config at $GIT_LOCAL"
else
  print_info "Local Git config already exists, skipping."
fi
