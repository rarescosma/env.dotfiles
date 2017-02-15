# -- Zsh -----------------------------------------------------------------------
# Path to your oh-my-zsh configuration.
ZSH="$HOME/.oh-my-zsh"

# -- Editor --------------------------------------------------------------------
export EDITOR="subl3"
export VISUAL="subl3"
umask 002

# -- Theme ---------------------------------------------------------------------
# Set name of the theme to load.
# Look in <%- paths.oh_my_zsh %>/themes/
ZSH_THEME="ric"

# -- Plugins -------------------------------------------------------------------
plugins=(archlinux docker extract git z lxd zsh-syntax-highlighting)

# -- Env -----------------------------------------------------------------------
if [[ -f "$HOME/.env" ]]; then
    source $HOME/.env
fi

# -- Oh My Zsh -----------------------------------------------------------------
DISABLE_AUTO_UPDATE="true"
source $ZSH/oh-my-zsh.sh

# -- Options -------------------------------------------------------------------
unsetopt correct_all
unsetopt correct

# -- Aliases -------------------------------------------------------------------
if [[ -f "$HOME/.aliases" ]]; then
    source $HOME/.aliases
fi

# -- X11 -----------------------------------------------------------------------
if [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec startx -- -dpi 192
else
  # -- Agent -------------------------------------------------------------------
  envoy -t ssh-agent
  source <(envoy -p)

  # -- Wisdom ------------------------------------------------------------------
  clear
  fortune -a /usr/share/fortune/southpark | cowsay -f tux
fi

# ZAW
source /src/getbetter/env.zaw/zaw.zsh
bindkey '^R' zaw-history
bindkey -M filterselect '^R' down-line-or-history
bindkey -M filterselect '^S' up-line-or-history
bindkey -M filterselect '^E' accept-search

zstyle ':filter-select:highlight' matched fg=yellow
zstyle ':filter-select' max-lines 5
zstyle ':filter-select' case-insensitive yes # enable case-insensitive 
zstyle ':filter-select' extended-search yes # see below

