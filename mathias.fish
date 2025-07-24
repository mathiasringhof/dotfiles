alias l 'eza --icons'
alias ll 'eza -l --icons --git'
alias la 'eza -la --icons --git'
alias lt 'eza --tree --icons'

set PATH /opt/homebrew/bin /opt/local/bin /opt/local/sbin $PATH

set -gx LANG "en_US.utf-8"
set -gx LC_ALL "en_US.utf-8"
set -gx VISUAL nvim
set -gx EDITOR nvim

kubectl completion fish | source
helm completion fish | source
zoxide init fish --cmd j | source
