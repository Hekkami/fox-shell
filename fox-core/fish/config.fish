set -gx EDITOR nvim
set -gx VISUAL nvim

fish_add_path "$HOME/.local/bin"

if command -v mise &>/dev/null
    mise activate fish | source
end

if status is-interactive
    set -g fish_greeting
end

fish_vi_key_bindings

set -gx STARSHIP_CONFIG "$HOME/.cache/starship/config.toml"
starship init fish | source
zoxide init fish | source

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    command rm -f -- "$tmp"
end
