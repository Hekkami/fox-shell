#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/install/utils.sh"

INSTALL_DIR="$REPO_ROOT/install"
LOG_DIR="$REPO_ROOT/logs"
LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "$LOG_DIR"

get_version() {
  local version
  version=$(git describe --tags --exact-match 2>/dev/null)
  if [ -z "$version" ]; then
    version="v0-dev"
  fi
  echo "$version"
}
VERSION=$(get_version)

exec > >(tee -a "$LOG_FILE") 2>&1

clear
echo "====================================================="
echo "       🚀 Fox Shell $VERSION Modular Installer       "
echo "====================================================="
echo ""
echo -e "${BLUE}──────────────────────────────────────────────────────────${NC}"
echo " Hey! Welcome and thank you for trying Fox Shell!"
echo " If you have any suggestions, feel free to open an issue in the repo."
echo ""
echo " This setup will automatically deploy all mandatory core"
echo " components and dotfiles, and will prompt you for optional"
echo " user and developer applications near the end."
echo ""
echo -e "${BLUE}──────────────────────────────────────────────────────────${NC}"
echo -e " Crafted by 🦊 Hek Fox | Indie Dev & Founder at Hekkami 🐺❄️"
echo " (Home of Fox Shell, upcoming open-source tools & more)"
echo -e "${BLUE}──────────────────────────────────────────────────────────${NC}"
echo ""

if prompt_app_yn "Do you want to update the system first? (Recommended: sudo pacman -Syu)" "y"; then
  print_info "Updating system packages..."
  if retry_command sudo pacman -Syu --noconfirm; then
    print_success "System updated successfully."
  else
    print_warning "System update failed. Continuing anyway — you may want to resolve this manually."
  fi
else
  print_warning "Skipping system update."
fi

echo ""

get_module_description() {
  case "$1" in
  "01-base-packages.sh") echo "Essential system packages (Hyprland, Waybar, Yazi, etc.)" ;;
  "02-paru.sh") echo "AUR helper (Paru)" ;;
  "03-sddm-theme.sh") echo "SDDM Display Manager & Silent theme" ;;
  "04-dev-tools.sh") echo "Developer tools (Docker & Mise)" ;;
  "05-gitconfig.sh") echo "Git credentials & global configuration (No ssh keys)" ;;
  "06-fish.sh") echo "Shell environment (Fish)" ;;
  "07-symlinks.sh") echo "Dotfiles symlinking (~/.config, ~/.gitconfig, bin)" ;;
  "08-user-apps.sh") echo "User Applications (Browsers, Media, etc.)" ;;
  "09-dev-apps.sh") echo "Developer Applications (IDEs, Docker, etc.)" ;;
  *) echo "Additional module ($1)" ;;
  esac
}

is_module_optional() {
  case "$1" in
  "08-user-apps.sh" | "09-dev-apps.sh")
    return 0
    ;;
  *)
    return 1
    ;;
  esac
}

# --- EXECUTE MODULES ---
declare -a SUMMARY_OK=()
declare -a SUMMARY_FAILED=()
declare -a SUMMARY_SKIPPED=()

if [ -d "$INSTALL_DIR" ]; then
  for script in "$INSTALL_DIR"/*.sh; do
    if [ -f "$script" ]; then
      script_name=$(basename "$script")

      if [ "$script_name" = "utils.sh" ]; then
        continue
      fi

      module_desc=$(get_module_description "$script_name")

      echo -e "${BLUE}──────────────────────────────────────────────────────────${NC}"

      should_install=false
      if is_module_optional "$script_name"; then
        if prompt_yn "Install $module_desc?" "y"; then
          should_install=true
        fi
      else
        print_info "Running mandatory module: $module_desc..."
        should_install=true
      fi

      if [ "$should_install" = true ]; then
        if bash "$script"; then
          SUMMARY_OK+=("$script_name — $module_desc")
        else
          print_warning "$script_name failed. Continuing with the next module..."
          SUMMARY_FAILED+=("$script_name — $module_desc")
        fi
      else
        print_warning "Skipping $script_name."
        SUMMARY_SKIPPED+=("$script_name — $module_desc")
      fi
    fi
  done
else
  echo -e "${RED}[ERROR]${NC} The 'install/' modules directory was not found."
  exit 1
fi

echo ""
echo -e "${BLUE}──────────────────────────────────────────────────────────${NC}"
echo "Installation summary:"
for m in "${SUMMARY_OK[@]}"; do echo -e "  ${GREEN}[OK]${NC}      $m"; done
for m in "${SUMMARY_FAILED[@]}"; do echo -e "  ${RED}[FAILED]${NC}  $m"; done
for m in "${SUMMARY_SKIPPED[@]}"; do echo -e "  ${YELLOW}[SKIPPED]${NC} $m"; done
echo ""
print_info "Full log saved to: $LOG_FILE"

if [ "${#SUMMARY_FAILED[@]}" -gt 0 ]; then
  echo ""
  print_warning "Some modules failed. Check the log above (or $LOG_FILE), fix the underlying issue, and re-run ./setup.sh — modules that already completed are safe to skip and won't be repeated."
fi

echo ""
echo "======================================================"
echo " 🎉 Fox Shell $VERSION installation process finished! "
echo "======================================================"

# --- REBOOT PROMPT (Default: Yes) ---
if prompt_yn "Would you like to reboot your system now to apply all changes?" "y"; then
  print_info "Rebooting system..."
  sudo reboot
else
  print_info "Please remember to reboot your system later manually."
fi
