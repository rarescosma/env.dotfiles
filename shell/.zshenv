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

# -- fzf! ----------------------------------------------------------------------
export FZF_TMUX=1
export FZF_DEFAULT_OPTS="--exact --extended --cycle --reverse \
--bind change:top --bind ctrl-e:accept --expect=enter"
FZF_CTRL_T_COMMAND='fd --type file --follow --hidden --exclude .git'
FZ_CMD=j
FZ_SUBDIR_CMD=jj
