safe_source() {
    [[ -f "$1" ]] && source "$1" || echo "Warning: $1 not found"
}

setopt autocd histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select

safe_source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
eval "$(zoxide init zsh --cmd j)"
eval "$(starship init zsh)"
# eval "$(atuin init zsh)"
source <(fzf --zsh)

export EDITOR=nvim
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

safe_source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
