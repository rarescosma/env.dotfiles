set -a

# locale
LANG=en_US.UTF-8
LANGUAGE=en_US
LC_MONETARY=en_US.UTF-8
LC_TIME=en_US.UTF-8
LC_CTYPE=en_US.UTF-8
LC_COLLATE="C"

# xdg
XDG_CONFIG_HOME=$HOME/.config
XDG_DATA_HOME=$HOME/.local/share
XDG_STATE_HOME=$HOME/.local/state
XDG_CACHE_HOME=$HOME/.cache

# path
PATH=${HOME}/.local/bin:${HOME}/bin:${PATH}

# clean home
AUTOENV_AUTH_FILE=$XDG_STATE_HOME/autoenv/authorized_list
AWS_SHARED_CREDENTIALS_FILE=$XDG_CONFIG_HOME/aws/credentials
AWS_CONFIG_FILE=$XDG_CONFIG_HOME/aws/config
CARGO_HOME=$XDG_DATA_HOME/cargo
DOCKER_CONFIG=$XDG_CONFIG_HOME/docker
GNUPGHOME=$XDG_DATA_HOME/gnupg
GOPATH=$XDG_DATA_HOME/go
_JAVA_OPTIONS="$_JAVA_OPTIONS -Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java"
NPM_PACKAGES=$XDG_CACHE_HOME/npm-packages
NVM_DIR=$XDG_CACHE_HOME/nvm
PARALLEL_HOME=$XDG_CONFIG_HOME/parallel
PASSWORD_STORE_DIR=$XDG_DATA_HOME/pass
PYENV_ROOT=$XDG_DATA_HOME/pyenv
PYLINTHOME=$XDG_CACHE_HOME/pylint
PYLINTRC=$XDG_CONFIG_HOME/pylint/config
RUSTUP_HOME=$XDG_DATA_HOME/rustup
SCREENRC=$XDG_CONFIG_HOME/screen/screenrc
SKAFFOLD_CONFIG=$XDG_CONFIG_HOME/skaffold
LESSHISTFILE=-

# progs
EDITOR=nvim
VISUAL=nvim

AUTOENV_IN_FILE=.autoenv
AUTOENV_OUT_FILE=.autoout
BAT_THEME=gruvbox-dark
DIFFPROG=meld
DOCKER_BUILDKIT=1
FZ_CMD=j
FZ_SUBDIR_CMD=jj
FZF_CTRL_T_COMMAND="fd --type file --follow --hidden --exclude .git"
FZF_DEFAULT_OPTS="--exact --extended --cycle --reverse --bind change:top --bind ctrl-e:accept --expect=enter"
FZF_TMUX=1
IDEA_VERSION=2022.3

# pkm
VAULT_DIR="${HOME}/sync/pkm/rar"
VAULT_MEDIA="_Media"

# zsh
_VENDOR=${HOME}/src/env/dotfiles/_vendor
DISABLE_AUTO_UPDATE=true
TERMINFO=/usr/share/terminfo
ZSH=${_VENDOR}/oh-my-zsh
ZSH_DISABLE_COMPFIX=true

set +a
