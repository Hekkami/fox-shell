#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

print_info "Creating symlinks for dotfiles..."

declare -A TARGETS=(
  ["$HOME/.config"]="hypr fox-themes"
  ["$HOME"]="git"
)

MARKER_DIR="$HOME/.config/fox-shell"
MARKER_FILE="$MARKER_DIR/shell.initialized"

if [ ! -f "$MARKER_FILE" ]; then
  print_info "Performing first-run Neovim cache cleanup..."
  rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
  mkdir -p "$MARKER_DIR"
  touch "$MARKER_FILE"
  print_success "Neovim cache cleaned."
else
  print_info "Neovim cleanup already performed on a previous run."
fi

for dest_dir in "${!TARGETS[@]}"; do
  for mod in ${TARGETS[$dest_dir]}; do
    src="$FOX_CORE/$mod"

    if [[ -d "$src" ]]; then
      if [[ "$dest_dir" == "$HOME" ]]; then
        print_info "Linking contents of module '$mod' directly into $HOME..."

        for file_path in "$src"/*; do
          [[ -e "$file_path" ]] || continue
          filename="$(basename "$file_path")"

          target_filename=".$filename"
          dest="$HOME/$target_filename"

          if [[ -L "$dest" && $(readlink "$dest") == "$file_path" ]]; then
            print_info "$target_filename link is already created."
            continue
          fi

          if [[ -e "$dest" || -L "$dest" ]]; then
            print_warning "Existing $dest found. Backing up to $BK..."
            mkdir -p "$BK"
            cp -rL "$dest" "$BK/"
            rm -rf "$dest"
          fi

          ln -s "$file_path" "$dest"
          print_success "Linked file: $filename -> $dest"
        done
      else
        dest="$dest_dir/$mod"

        if [[ -L "$dest" && $(readlink "$dest") == "$src" ]]; then
          print_info "$mod link is already created."
          continue
        fi

        if [[ -e "$dest" || -L "$dest" ]]; then
          print_warning "Existing $dest found. Backing up to $BK..."
          mkdir -p "$BK"
          cp -rL "$dest" "$BK/"
          rm -rf "$dest"
        fi

        mkdir -p "$(dirname "$dest")"
        ln -s "$src" "$dest"
        print_success "Linked directory: $mod -> $dest"

        if [[ "$mod" == "hypr" ]] && command -v hyprctl &>/dev/null; then
          hyprctl reload &>/dev/null || true
        fi
      fi
    else
      print_warning "Module not found: $src"
    fi
  done
done

print_info "Linking custom binaries from $BIN_SRC to $BIN_DEST..."
mkdir -p "$BIN_DEST"
if [[ -d "$BIN_SRC" ]]; then
  for binary in "$BIN_SRC"/*; do
    [ -f "$binary" ] || continue
    bin_name="$(basename "$binary")"
    dest_path="$BIN_DEST/$bin_name"

    if [[ -L "$dest_path" && $(readlink "$dest_path") == "$binary" ]]; then
      print_info "Link for binary $bin_name is already created."
      continue
    fi

    chmod +x "$binary"
    ln -sfn "$binary" "$dest_path"
    print_success "Linked binary $bin_name -> $dest_path"
  done
fi

print_success "Dotfiles and binaries linking completed successfully."
