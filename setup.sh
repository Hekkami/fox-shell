REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FOX_CORE="$REPO_ROOT/fox-core"
BK="$REPO_ROOT/backups/$(date +%Y%m%d-%H%M%S)"

declare -A TARGETS=(
  ["$HOME/.config"]="hypr"
)

for dest_dir in "${!TARGETS[@]}"; do
  for mod in ${TARGETS[$dest_dir]}; do
    src="$FOX_CORE/$mod"
    dest="$dest_dir/$mod"

    if [[ -d "$src" ]]; then
      if [[ -L "$dest" && $(readlink "$dest") == "$src" ]]; then
        echo "$mod link is alreary created"
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
