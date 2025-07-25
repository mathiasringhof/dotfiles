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

# Preview file content using bat (https://github.com/sharkdp/bat)
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target,Library,crypt
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"
# Print tree structure in the preview window
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target,Library,crypt
  --preview 'tree -C {}'"
fzf --fish | source
