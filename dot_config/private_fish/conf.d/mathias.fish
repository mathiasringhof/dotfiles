alias l 'eza --icons'
alias ll 'eza -l --icons --git'
alias la 'eza -la --icons --git'
alias lt 'eza --tree --icons'
alias vi nvim

set PATH /opt/homebrew/bin /opt/local/bin /opt/local/sbin $PATH

set -gx LANG "en_US.utf-8"
set -gx LC_ALL "en_US.utf-8"
set -gx VISUAL nvim
set -gx EDITOR nvim

fish_vi_key_bindings

if type -q kubectl
    kubectl completion fish | source
end
if type -q helm
    helm completion fish | source
end
zoxide init fish --cmd j | source

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end
