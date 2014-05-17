# -- Zsh -----------------------------------------------------------------------
# Path to your oh-my-zsh configuration.
ZSH="<%- zsh.path_oh_my_zsh %>"

# -- Editor --------------------------------------------------------------------
EDITOR="subl"

# -- Theme ---------------------------------------------------------------------
# Set name of the theme to load.
# Look in <%- zsh.path_oh_my_zsh %>/themes/
ZSH_THEME="<%- zsh.theme_oh_my_zsh %>"

# -- Plugins -------------------------------------------------------------------
# Plugins can be found in <%- zsh.path_oh_my_zsh %>/plugins/
# Custom plugins may be added to <%- zsh.path_oh_my_zsh %>/custom/plugins/
#
# Which plugins would you like to load?
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(<%- zsh.zsh_plugins %>)

# -- Oh My Zsh -----------------------------------------------------------------
source $ZSH/oh-my-zsh.sh

# -- Options -------------------------------------------------------------------
unsetopt correct_all
unsetopt correct

# -- Aliases -------------------------------------------------------------------
source $HOME/.dotfiles/.aliases

# -- Navigation ----------------------------------------------------------------
source $HOME/.dotfiles/.navigation

if [[ -f "$HOME/.aliases" ]]; then
    source $HOME/.aliases
fi
