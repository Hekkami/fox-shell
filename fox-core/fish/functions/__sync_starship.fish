function __sync_starship --on-event fish_prompt
    set -l base "$HOME/.config/starship/starship.toml"
    set -l palette "$HOME/.config/fox-themes/generated/starship-palette.toml"
    set -l out "$HOME/.cache/starship/config.toml"

    mkdir -p (dirname "$out")
    if test -f "$base"
        if test -f "$palette"
            cat "$base" "$palette" >"$out"
        else
            cp "$base" "$out"
        end
        set -gx STARSHIP_CONFIG "$out"
    end
end
