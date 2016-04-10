# -- Zsh -----------------------------------------------------------------------
# Path to your oh-my-zsh configuration.
ZSH="$HOME/.oh-my-zsh"

# -- Editor --------------------------------------------------------------------
EDITOR="subl3"
VISUAL="subl3"

# -- Theme ---------------------------------------------------------------------
# Set name of the theme to load.
# Look in <%- paths.oh_my_zsh %>/themes/
ZSH_THEME="ric"

# -- Plugins -------------------------------------------------------------------
# Plugins can be found in <%- paths.oh_my_zsh %>/plugins/
# Custom plugins may be added to <%- paths.oh_my_zsh %>/custom/plugins/
#
# Which plugins would you like to load?
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(archlinux git)

# -- Env -----------------------------------------------------------------------
if [[ -f "$HOME/.env" ]]; then
    source $HOME/.env
fi

# -- Oh My Zsh -----------------------------------------------------------------
source $ZSH/oh-my-zsh.sh

# -- Options -------------------------------------------------------------------
unsetopt correct_all
unsetopt correct

# -- Aliases -------------------------------------------------------------------
if [[ -f "$HOME/.aliases" ]]; then
    source $HOME/.aliases
fi


# -- Wisdom --------------------------------------------------------------------
if [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec startx -- -dpi 192
else
  if [[ -f "$HOME/.ssh/init_agent.zsh" ]]; then
    source $HOME/.ssh/init_agent.zsh
  fi
  clear
  fortune -a /usr/share/fortune/southpark | cowsay -f tux
fi

