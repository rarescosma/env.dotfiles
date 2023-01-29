# Sane defaults
[[ -v enable_devel ]] || enable_devel=(kubectl python aws rust nvm)

alias vi="$EDITOR"
alias vim="$EDITOR"

# -- Turtles -------------------------------------------------------------------
## scum a docker image
dscum() {
    local entrypoint
    if [[ "$1" == "sh" ]]; then
        entrypoint="/bin/sh"
        shift
    else
        entrypoint="/bin/bash"
    fi
    docker run \
        --rm -it \
        --name="dscum-$(pwgen -A01)" \
        --entrypoint="$entrypoint" "$@"
}

## docker ps with port information
dps() {
  docker ps $@ \
    --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}" \
    | grep -v pause
}

if [[ "$enable_devel" =~ "kubectl" ]]; then
  source ~/.config/zsh/kube.zsh
fi

if [[ "$enable_devel" =~ "aws" ]]; then
  export AWS_CREDENTIAL_FILE="${HOME}/.aws/credentials"
  export AWS_PROFILE="default"
  export EC2_REGION="eu-west-1"
  _aws_zsh_completer_path="${HOME}/.local/bin/aws_zsh_completer.sh"
  [ -f "$_aws_zsh_completer_path" ] && source "$_aws_zsh_completer_path"
  unset _aws_zsh_completer_path

  ## list ec2 instances belonging to team
  ec2-list() {
    local team="$1"; shift
    ec2-toys list --filters "Name=instance-state-name,Values=running Name=tag:Team,Values=$team" | grep linux
  }

  ## output instance IP after filtering
  ec2-ip() {
    memoize ec2-list $TEAM_TAG | fzf_cmd --query "$*" | awk '{print $2}'
  }
fi

# -- Python --------------------------------------------------------------------
if [[ "$enable_devel" =~ "python" ]]; then
  export PATH="${PYENV_ROOT}/shims:$PATH"

  export PIPENV_VENV_IN_PROJECT=1
  export PIPENV_IGNORE_VIRTUALENVS=0
  export PIPENV_HIDE_EMOJIS=1
  export PIPENV_NOSPIN=1

  alias pipu='pip install -U pip'
  alias pe='pipenv'

  ## create pipenv-based .venv
  nvenv() {
    local prompt
    local root
    if [ ! -d ".venv" ]; then
      root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
      if [ -z "$1" ]; then
        prompt=$(basename $root)
      else
        prompt="${1}"
        shift
      fi
      python -mvenv .venv --prompt "${prompt}"
    fi

    deactivate 2>/dev/null

    if [ -f pyproject.toml ]; then
      poetry install
    elif [ -f Pipfile ]; then
      pipenv install --dev --skip-lock "$@"
    else
      [ -f requirements.txt ] && pipenv install -r requirements.txt --skip-lock "$@"
    fi

    source .venv/bin/activate

    ln -sf "$_VENDOR/../devel/.pythonenv" .autoenv
    echo "deactivate" > .autoout
    touch .env
  }

  ## delete/cleanup .venv
  rvenv() {
    deactivate 2>/dev/null
    rm -rf .venv .env Pipfile Pipfile.lock .python-version
  }

  revenv() {
    local _prompt
    local _root
    _root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    if [ -z "$1" ]; then
      _prompt=$(basename $_root)
    else
      _prompt="${1}"
      shift
    fi
    deactivate 2>/dev/null
    rm -rf .venv
    python -mvenv .venv --prompt "${_prompt}"
  }
fi

if [[ "$enable_devel" =~ "golang" ]]; then
  PATH="${PATH}:${GOPATH}/bin"
fi

if [[ "$enable_devel" =~ "rust" ]]; then
  PATH="${PATH}:${CARGO_HOME}/bin"
  export SCCACHE_CACHE_SIZE="2G"
fi

if [[ "$enable_devel" =~ "node" ]]; then
  PATH="${PATH}:${NPM_PACKAGES}/bin"
  NODE_PATH="${NPM_PACKAGES}/lib/node_modules:${NODE_PATH}"
fi

if [[ "$enable_devel" =~ "nvm" ]]; then
  source /usr/share/nvm/nvm.sh --no-use
  source /usr/share/nvm/install-nvm-exec
fi

[[ -f /opt/asdf-vm/asdf.sh ]] && . /opt/asdf-vm/asdf.sh
