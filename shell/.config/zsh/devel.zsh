# Sane defaults
[[ -v enable_devel ]] || enable_devel=(kubectl python aws rust nvm gcloud)

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

  # restore old virtualenv prompt when using direnv
  # https://github.com/direnv/direnv/wiki/Python#restoring-the-ps1
  setopt PROMPT_SUBST
  show_virtual_env() {
    if [[ -n "$VIRTUAL_ENV_PROMPT" && -n "$DIRENV_DIR" ]]; then
      echo "($VIRTUAL_ENV_PROMPT) "
    fi
  }
  PS1='$(show_virtual_env)'$PS1

  ## create a direnv powered virtualenv
  nvenv() {
    ln -sf "$_VENDOR/../devel/.envrc.python" .envrc
    ln -sf "$_VENDOR/../devel/.envrc.python-install" .envrc.install
    direnv allow
  }

  ## delete/cleanup .venv
  rvenv() {
    sudo /sbin/rm -rf .venv .envrc .envrc.install
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

[[ -f /opt/asdf-vm/asdf.sh ]] && . /opt/asdf-vm/asdf.sh

if [[ "$enable_devel" =~ "gcloud" ]]; then
  # The next line updates PATH for the Google Cloud SDK.
  if [ -f "${HOME}/var/google-cloud-sdk/path.zsh.inc" ]; then . "${HOME}/var/google-cloud-sdk/path.zsh.inc"; fi

  # The next line enables shell command completion for gcloud.
  if [ -f "${HOME}/var/google-cloud-sdk/completion.zsh.inc" ]; then . "${HOME}/var/google-cloud-sdk/completion.zsh.inc"; fi
fi
