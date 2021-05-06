# -- Base ----------------------------------------------------------------------
PATH="${HOME}/.local/bin:${HOME}/bin:${PATH}"
LANG=en_US.UTF-8
LC_CTYPE=en_US.UTF-8
LC_COLLATE="C"

# -- Editor --------------------------------------------------------------------
export VISUAL="vim"
export EDITOR="${VISUAL}"

# -- Oh My Zsh -----------------------------------------------------------------
_VENDOR="${HOME}/src/env.dotfiles/_vendor"
ZSH="${_VENDOR}/oh-my-zsh"
DISABLE_AUTO_UPDATE="true"
ZSH_DISABLE_COMPFIX="true"
export TERMINFO=/usr/share/terminfo

# -- fzf! ----------------------------------------------------------------------
export FZF_TMUX=1
export FZF_DEFAULT_OPTS="--exact --extended --cycle --reverse \
--bind change:top --bind ctrl-e:accept --expect=enter"
FZF_CTRL_T_COMMAND='fd --type file --follow --hidden --exclude .git'
FZ_CMD=j
FZ_SUBDIR_CMD=jj

# -- kube ----------------------------------------------------------------------
export CLUSTER="k0"
