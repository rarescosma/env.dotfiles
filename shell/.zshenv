# -- Base ----------------------------------------------------------------------
PATH="${PATH}:${HOME}/bin:${HOME}/.local/bin"
LANG=en_US.UTF-8
LC_CTYPE=en_US.UTF-8
LC_COLLATE="C"

# -- Editor --------------------------------------------------------------------
VISUAL="subl3 -w"
EDITOR="${VISUAL}"

# -- Oh My Zsh -----------------------------------------------------------------
ZSH="${HOME}/src/env.dotfiles/_vendor/oh-my-zsh"
ZSH_THEME="ric"
DISABLE_AUTO_UPDATE="true"
plugins=(gitalias archlinux docker git lxd zsh-syntax-highlighting kubectl zsh-autosuggestions)
