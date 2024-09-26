set -a

# dns
DEFAULT_DNS=1.1.1.1

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

# clean home
AWS_SHARED_CREDENTIALS_FILE=$XDG_CONFIG_HOME/aws/credentials
AWS_CONFIG_FILE=$XDG_CONFIG_HOME/aws/config
CARGO_HOME=$XDG_DATA_HOME/cargo
DOCKER_CONFIG=$XDG_CONFIG_HOME/docker
GNUPGHOME=$XDG_DATA_HOME/gnupg
GOPATH=$XDG_DATA_HOME/go
_JAVA_OPTIONS="$_JAVA_OPTIONS -Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java"
LESSHISTFILE=-
NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
NVM_DIR=$XDG_CACHE_HOME/nvm
PARALLEL_HOME=$XDG_CONFIG_HOME/parallel
PASSWORD_STORE_DIR=$XDG_DATA_HOME/pass
PYENV_ROOT=$XDG_DATA_HOME/pyenv
PYLINTHOME=$XDG_CACHE_HOME/pylint
PYLINTRC=$XDG_CONFIG_HOME/pylint/config
RIPGREP_CONFIG_PATH=$XDG_CONFIG_HOME/rg/flags
RUSTUP_HOME=$XDG_DATA_HOME/rustup
SCREENRC=$XDG_CONFIG_HOME/screen/screenrc
SKAFFOLD_CONFIG=$XDG_CONFIG_HOME/skaffold
SKAFFOLD_CACHE_FILE=$XDG_CACHE_HOME/skaffold/cache
ZSH_EVALCACHE_DIR=$XDG_CACHE_HOME/evalcache

# progs
EDITOR=nvim
VISUAL=nvim

BAT_THEME=gruvbox-dark
DIFFPROG=meld
DOCKER_BUILDKIT=1
FZ_CMD=j
FZ_SUBDIR_CMD=jj
FZF_CTRL_T_COMMAND="fd --type file --follow --hidden --exclude .git"
FZF_ALT_C_COMMAND="fd --type directory --follow --hidden"
FZF_DEFAULT_OPTS="--exact --extended --cycle --reverse --bind change:top --bind ctrl-e:accept --expect=enter"
FZF_TMUX=1
IDEA_VERSION=2024.2

# pkm
VAULT_ROOT="${HOME}/sync/pkm"
VAULT_DIR="${VAULT_ROOT}/current"

# zsh
_VENDOR=${HOME}/src/env/dotfiles/_vendor
_DIRENV=${HOME}/src/env/dotfiles/direnv
DISABLE_AUTO_UPDATE=true
TERMINFO=/usr/share/terminfo
ZSH=${_VENDOR}/oh-my-zsh
ZSH_DISABLE_COMPFIX=true

[[ -f ~/.local/env ]] && source ~/.local/env

set +a
