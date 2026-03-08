# Created by kash
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# History substring search (up/down arrow searches history by what you've typed)
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

alias hyprconf="micro ~/.config/hypr/hyprland.conf"
alias caeconf="micro ~/.config/caelestia/shell.json"
alias fetchconf="micro ~/.config/fastfetch/config.jsonc"
alias caefiles="cd ~/.config/quickshell/caelestia"
alias matrix="unimatrix -c cyan -s 93 -f -l kkns -a"
alias matrixb="cmatrix -C blue -u 7"
alias matrixc="cmatrix -C cyan -u 8 -s"
alias unmount='udisksctl unmount -b /dev/sda1 && udisksctl power-off -b /dev/sda'

export QT_QPA_PLATFORMTHEME=qt6ct
export XDG_MENU_PREFIX=arch-

eval "$(starship init zsh)"

export EDITOR=micro
export VISUAL=micro
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
alias cheat='f() {curl "cheat.sh/$1" }; f'
cat ~/.local/state/caelestia/sequences.txt 2>/dev/null
