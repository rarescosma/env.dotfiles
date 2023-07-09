# Sane defaults
[[ -v enable_devel ]] || enable_devel=(kube python rust)

alias vi="$EDITOR"
alias vim="$EDITOR"

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
  export PIPENV_VENV_IN_PROJECT=1
  export PIPENV_IGNORE_VIRTUALENVS=0
  export PIPENV_HIDE_EMOJIS=1
  export PIPENV_NOSPIN=1

  alias pipu='pip install -U pip'
  alias pyv="python '$_DIRENV/which.py'"

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
fi

if [[ "$enable_devel" =~ "golang" ]]; then
  PATH="${PATH}:${GOPATH}/bin"
fi

if [[ "$enable_devel" =~ "rust" ]]; then
  PATH="${PATH}:${CARGO_HOME}/bin"
  export SCCACHE_CACHE_SIZE="2G"

  if test -f ${XDG_DATA_HOME}/cargo/env; then
    source ${XDG_DATA_HOME}/cargo/env
  fi
fi

if [[ "$enable_devel" =~ "node" ]]; then
  PATH="${PATH}:${NPM_PACKAGES}/bin"
  NODE_PATH="${NPM_PACKAGES}/lib/node_modules:${NODE_PATH}"
fi

if [[ "$enable_devel" =~ "nvm" ]] && test -d /usr/share/nvm; then
  source /usr/share/nvm/nvm.sh --no-use
  source /usr/share/nvm/install-nvm-exec
fi
