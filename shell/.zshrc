[[ -f ~/.local/env ]] && source ~/.local/env

source /usr/share/LS_COLORS/dircolors.sh

source ~/.zsh/oh-my-vendor.zsh
source ~/.zsh/fzf.zsh

source ~/.zsh/prompt.zsh

source ~/.zsh/opts.zsh
source ~/.zsh/keybindings.zsh
source ~/.zsh/functions.zsh

source ~/.zsh/devel.zsh

source ~/.zsh/misc.zsh

[[ -f ~/.local/functions ]] && source ~/.local/functions

# -- X11 -----------------------------------------------------------------------
if [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec startx -- -dpi 144
else
  source ~/.zsh/fortune.zsh
fi
