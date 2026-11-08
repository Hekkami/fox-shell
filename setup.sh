#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/install/utils.sh"

declare -A TARGETS=(
  ["$HOME/.config"]="hypr fox-themes quickshell"
)

for dest_dir in "${!TARGETS[@]}"; do
  for mod in ${TARGETS[$dest_dir]}; do
    src="$FOX_CORE/$mod"
    dest="$dest_dir/$mod"

    if [[ -d "$src" ]]; then
      if [[ -L "$dest" && $(readlink "$dest") == "$src" ]]; then
        echo "$mod link is already created"
        continue
      fi

      if [[ -e "$dest" || -L "$dest" ]]; then
        mkdir -p "$BK"
        cp -rL "$dest" "$BK/"
        rm -rf "$dest"
      fi

      mkdir -p "$(dirname "$dest")"
      ln -s "$src" "$dest"
      echo " ✓ Linked: $mod -> $dest"
      if [[ "$mod" == "hypr" ]] && command -v hyprctl &>/dev/null; then
        hyprctl reload &>/dev/null
      fi
    else
      echo "⚠️ Module not found: $src"
    fi
  done
done

mkdir -p "$BIN_DEST"
if [[ -d "$BIN_SRC" ]]; then
  for binary in "$BIN_SRC"/*; do
    [ -f "$binary" ] || continue
    bin_name="$(basename "$binary")"
    dest_path="$BIN_DEST/$bin_name"

    if [[ -L "$dest_path" && $(readlink "$dest_path") == "$binary" ]]; then
      echo "Link for $bin_name is already created"
      continue
    fi

    chmod +x "$binary"
    ln -sfn "$binary" "$dest_path"
    echo "Linked binary $bin_name -> $dest_path"
  done
fi
