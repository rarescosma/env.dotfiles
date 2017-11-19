# -- Zsh -----------------------------------------------------------------------
# Path to your oh-my-zsh configuration.
ZSH="$HOME/src/env.oh-my-zsh"
ZSH_THEME="ric"
export ZSH_UNAME=$(uname)
plugins=(archlinux docker git z lxd zsh-syntax-highlighting kubectl zsh-autosuggestions)

# -- Editor --------------------------------------------------------------------
export VISUAL="subl3 -w"
export EDITOR="${VISUAL}"
umask 002

# -- Env -----------------------------------------------------------------------
[[ -f "$HOME/.env" ]] && source $HOME/.env
[[ -f "$HOME/.local/env" ]] && source $HOME/.local/env

# -- Oh My Zsh -----------------------------------------------------------------
DISABLE_AUTO_UPDATE="true"
source $ZSH/oh-my-zsh.sh

# -- Options -------------------------------------------------------------------
unsetopt correct_all
unsetopt correct

# -- Aliases -------------------------------------------------------------------
[[ -f "$HOME/.aliases" ]] && source $HOME/.aliases
[[ -f "$HOME/.local/aliases" ]] && source $HOME/.local/aliases

# -- ZAW! ----------------------------------------------------------------------
source "${HOME}/src/env.zaw/zaw.zsh"
bindkey '^R' zaw-history
bindkey -M filterselect '^R' down-line-or-history
bindkey -M filterselect '^S' up-line-or-history
bindkey -M filterselect '^E' accept-search

zstyle ':filter-select:highlight' matched fg=yellow
zstyle ':filter-select' max-lines 8
zstyle ':filter-select' case-insensitive yes # enable case-insensitive
zstyle ':filter-select' extended-search yes # see below

# -- X11 (Linux) ---------------------------------------------------------------
if [[ $ZSH_UNAME == 'Linux' ]]; then
  if [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    exec startx -- -dpi 144
  else
    envoy -t ssh-agent
    source <(envoy -p)
    clear
    fortune -a | cowsay -f tux
  fi
elif [[ $ZSH_UNAME == 'Darwin' ]]; then
  source ~/.zsh/completions/docker.zsh-completion
  source ~/.zsh/completions/docker-compose.zsh-completion
  compdef _docker docker
  compdef _docker-compose docker-compose
fi
