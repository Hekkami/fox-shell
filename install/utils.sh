REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

MIRRORS_REFRESHED_ONCE=""
refresh_mirrors_once() {
  [ -n "$MIRRORS_REFRESHED_ONCE" ] && return 0
  MIRRORS_REFRESHED_ONCE=1

  if command -v cachyos-rate-mirrors &>/dev/null; then
    print_warning "Re-ranking CachyOS mirrors before retrying (this can take a minute)..."
    sudo cachyos-rate-mirrors &>/dev/null || true
  elif command -v reflector &>/dev/null; then
    print_warning "Re-ranking Arch mirrors before retrying (this can take a minute)..."
    sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist &>/dev/null || true
  fi

  print_warning "Forcing a full database re-sync (pacman -Syy) in case the local index is pointing at a version the mirrors no longer have..."
  sudo pacman -Syy &>/dev/null || true
}

retry_command() {
  local attempts=3
  local delay=4
  local n=1
  until "$@"; do
    if [ "$n" -ge "$attempts" ]; then
      return 1
    fi
    print_warning "Attempt $n/$attempts failed, retrying in ${delay}s..."
    case "$*" in
    *pacman* | *paru*) refresh_mirrors_once ;;
    esac
    sleep "$delay"
    n=$((n + 1))
  done
}

pacman_app_healthy() {
  local app="$1"
  pacman -Qq "$app" &>/dev/null && pacman -Qk --quiet "$app" &>/dev/null
}

prompt_app_yn() {
  local prompt_text="$1"
  local default_val="${2:-y}"
  local yn_suffix="[Y/n]"
  local yn

  while true; do
    read -p "$(echo -e "${YELLOW}[?]${NC} $prompt_text $yn_suffix: ")" yn </dev/tty
    if [ -z "$yn" ]; then
      yn="$default_val"
    fi
    case $yn in
    [Yy]*) return 0 ;;
    [Nn]*) return 1 ;;
    *) echo "Please answer yes (y) or no (n)." ;;
    esac
  done
}

app_already_installed() {
  local app="$1"
  local fallback_func="${2:-}"

  if pacman -Qq "$app" &>/dev/null; then
    if pacman_app_healthy "$app"; then
      return 0
    fi
    print_warning "$app is installed but some of its files are missing or corrupted; will reinstall."
    return 1
  fi

  if [ -n "$fallback_func" ]; then
    local flatpak_id
    flatpak_id=$($fallback_func "$app")
    if [ -n "$flatpak_id" ] && flatpak info "$flatpak_id" &>/dev/null; then
      return 0
    fi
  fi

  return 1
}

install_pacman_apps() {
  local -n apps_ref=$1
  local fallback_func="${2:-}"

  for item in "${apps_ref[@]}"; do
    local app="${item%%:*}"
    local desc="${item#*:}"

    if app_already_installed "$app" "$fallback_func"; then
      print_success "$app is already installed, skipping."
      continue
    fi

    if ! prompt_app_yn "Do you want to install $app ($desc) via pacman?" "y"; then
      print_warning "Skipping $app."
      continue
    fi

    print_info "Installing $app..."
    local -a pacman_cmd=(sudo pacman -S --needed --noconfirm "$app")
    if pacman -Qq "$app" &>/dev/null; then
      pacman_cmd=(sudo pacman -S --noconfirm "$app")
    fi
    if retry_command "${pacman_cmd[@]}"; then
      print_success "$app installed via pacman."
      continue
    fi
    print_warning "Failed to install $app via pacman."

    if command -v paru &>/dev/null; then
      print_info "Trying $app via paru (AUR)..."
      local -a paru_cmd=(paru -S --needed --noconfirm "$app")
      if pacman -Qq "$app" &>/dev/null; then
        paru_cmd=(paru -S --noconfirm "$app")
      fi
      if retry_command "${paru_cmd[@]}"; then
        print_success "$app installed via AUR."
        continue
      fi
      print_warning "AUR installation for $app also failed."
    else
      print_warning "Paru is not installed, skipping AUR fallback for $app."
    fi
  done
}

install_aur_apps() {
  local -n apps_ref=$1
  local fallback_func=$2

  for item in "${apps_ref[@]}"; do
    local app="${item%%:*}"
    local desc="${item#*:}"

    if app_already_installed "$app" "$fallback_func"; then
      print_success "$app is already installed, skipping."
      continue
    fi

    if ! prompt_app_yn "Do you want to install $app ($desc) via paru (AUR)?" "y"; then
      print_warning "Skipping $app."
      continue
    fi

    print_info "Installing $app (review PKGBUILD if prompted)..."
    local -a paru_cmd=(paru -S --needed "$app")
    if pacman -Qq "$app" &>/dev/null; then
      paru_cmd=(paru -S "$app")
    fi

    if "${paru_cmd[@]}"; then
      print_success "$app installed via AUR."
      continue
    fi
  done
}
