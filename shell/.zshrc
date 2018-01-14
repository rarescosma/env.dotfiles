# -- Zsh -----------------------------------------------------------------------
# Path to your oh-my-zsh configuration.
ZSH="${HOME}/src/env.dotfiles/_vendor/oh-my-zsh"
ZSH_THEME="ric"
export ZSH_UNAME=$(uname)
plugins=(archlinux docker git lxd zsh-syntax-highlighting kubectl zsh-autosuggestions)

# -- Editor --------------------------------------------------------------------
export VISUAL="subl3 -w"
export EDITOR="${VISUAL}"
umask 002

# -- Env -----------------------------------------------------------------------
[[ -f "$HOME/.env" ]] && source $HOME/.env
[[ -f "$HOME/.local/env" ]] && source $HOME/.local/env

# -- Oh My Zsh -----------------------------------------------------------------
DISABLE_AUTO_UPDATE="true"
ZSH_DISABLE_COMPFIX="true"
source $ZSH/oh-my-zsh.sh

# -- Options -------------------------------------------------------------------
unsetopt correct_all
unsetopt correct

# -- Aliases -------------------------------------------------------------------
[[ -f "$HOME/.aliases" ]] && source $HOME/.aliases
[[ -f "$HOME/.local/aliases" ]] && source $HOME/.local/aliases

# -- fzf! ----------------------------------------------------------------------
PATH="$PATH:${ZSH}/../fzf/bin"
export FZF_TMUX=1
export FZF_DEFAULT_OPTS="--exact --extended --cycle --reverse \
--bind change:top --bind ctrl-e:accept --expect=enter"
source "${ZSH}/../fzf/shell/key-bindings.zsh"

export FZ_CMD=j
export FZ_SUBDIR_CMD=jj

if [[ -f $ZSH/../zplug/init.zsh ]]; then
    export ZPLUG_LOADFILE=${HOME}/.zplug.zsh
    source $ZSH/../zplug/init.zsh

    if ! zplug check --verbose; then
        printf "Install? [y/N]: "
        if read -q; then
            echo; zplug install
        fi
        echo
    fi
    zplug load
fi

unalias z

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
fi
