# Sane defaults
[[ -v enable_devel ]] || enable_devel=(rust python kube node)

command -v vi >/dev/null || alias vi="$EDITOR"
command -v vim >/dev/null || alias vim="$EDITOR"

# -- Turtles -------------------------------------------------------------------
## scum a docker image
dscum() {
  local unit="docker"
  local entrypoint
  if [[ "$1" == "sh" ]]; then
    entrypoint="/bin/sh"
    shift
  else
    entrypoint="/bin/bash"
  fi

  # ensure docker is up
  if type systemctl >/dev/null; then
    sudo systemctl is-active --quiet ${unit} || {
      sudo systemctl restart ${unit}
      while true; do
        docker ps 1>/dev/null && break
        sleep 1
      done
    }
  fi

  docker run --rm -it --name="dscum-$(pwgen -A01)" \
    --entrypoint="$entrypoint" "$@"
}

## docker ps with port information
unalias dps 2>/dev/null
dps() {
  docker ps $@ \
    --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}" \
    | grep -v pause
}

if [[ "$enable_devel" =~ "kube" ]]; then
  source ~/.config/zsh/kube.zsh
fi

# -- Python --------------------------------------------------------------------
if [[ "$enable_devel" =~ "python" ]]; then
  if command -v pipenv >/dev/null; then
    export PIPENV_VENV_IN_PROJECT=1
    export PIPENV_IGNORE_VIRTUALENVS=0
    export PIPENV_HIDE_EMOJIS=1
    export PIPENV_NOSPIN=1
  fi

  alias pipu='pip install -U pip'

  ## create a direnv powered virtualenv
  nvenv() {
    ln -sf "$_DIRENV/python.envrc" .envrc
    ln -sf "$_DIRENV/python-install.envrc" .envrc.install
    direnv allow
  }

  ## delete/cleanup .venv
  rvenv() {
    RM=/sbin/rm
    test -x $RM || RM=/bin/rm
    sudo $RM -rf .venv .envrc .envrc.install
  }

  alias revenv="rvenv; nvenv"

  if command -v pyenv >/dev/null; then
    export PYENV_ROOT="$HOME/.local/share/pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
  fi
fi

if [[ "$enable_devel" =~ "golang" ]]; then
  PATH="${PATH}:${GOPATH}/bin"
fi

if [[ "$enable_devel" =~ "rust" ]]; then
  export SCCACHE_CACHE_SIZE="8G"

  if test -f ${XDG_DATA_HOME}/cargo/env; then
    source ${XDG_DATA_HOME}/cargo/env
  fi
  PATH="${PATH}:${HOME}/.local/share/cargo/bin"
fi

if [[ "$enable_devel" =~ "node" ]]; then
  PATH="${PATH}:${XDG_DATA_HOME}/npm/bin"
  export NODE_PATH="${XDG_DATA_HOME}/npm/lib/node_modules:${NODE_PATH}"
fi

if [[ "$enable_devel" =~ "nvm" ]] && test -d /usr/share/nvm; then
  source /usr/share/nvm/nvm.sh --no-use
  source /usr/share/nvm/install-nvm-exec
fi

if [[ "$enable_devel" =~ "sdk" ]] && test -d $HOME/.sdkman/bin; then
    source "${HOME}/.sdkman/bin/sdkman-init.sh"
fi
