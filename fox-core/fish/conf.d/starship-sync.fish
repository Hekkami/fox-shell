function __sync_starship
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

function __on_theme_reload --on-signal USR1
    __sync_starship
    commandline -f repaint
end

function __on_preexec_sync --on-event fish_preexec
    __sync_starship
end

__sync_starship
