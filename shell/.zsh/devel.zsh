# Sane defaults
[[ -v enable_devel ]] || enable_devel=(kubectl python aws golang)

# -- Turtles -------------------------------------------------------------------
dscum() {
    # scum a docker image off
    docker run \
        --rm -it \
        --name="dscum-$(pwgen -A01)" \
        --entrypoint="/bin/bash" "$@"
}


if [[ "$enable_devel" =~ "kubectl" ]]; then
  source "${HOME}/.zsh/kube.zsh"
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
  export PYENV_ROOT="${HOME}/.pyenv"
  if [[ -x "${PYENV_ROOT}/bin/pyenv" ]]; then
    export PATH="${PATH}:${PYENV_ROOT}/bin"
  fi
  if (( $+commands[pyenv] )); then
    eval "$(pyenv init -)"
  fi

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

    if [ -f Pipfile ]; then
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
fi

if [[ "$enable_devel" =~ "golang" ]]; then
  PATH="${PATH}:${HOME}/.golang/bin"
  export GOPATH="${HOME}/.golang"
fi

if [[ "$enable_devel" =~ "rust" ]]; then
  PATH="${PATH}:${HOME}/.cargo/bin"
fi

if [[ "$enable_devel" =~ "node" ]]; then
  NPM_PACKAGES="${HOME}/.npm-packages"
  PATH="${PATH}:${NPM_PACKAGES}/bin"
  NODE_PATH="${NPM_PACKAGES}/lib/node_modules:${NODE_PATH}"
fi

if [[ "$enable_devel" =~ "nvm" ]]; then
  [ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"
  source /usr/share/nvm/nvm.sh --no-use
  source /usr/share/nvm/install-nvm-exec
fi

if [[ "$enable_devel" =~ "php" ]]; then
  PATH="${PATH}:${HOME}/.composer/vendor/bin"
fi

if [[ "$enable_devel" =~ "java" ]]; then
  export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_141.jdk/Contents/Home"
  export SDKMAN_DIR="${HOME}/.sdkman"
  [[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]] && source "${HOME}/.sdkman/bin/sdkman-init.sh"
fi

if [[ "$enable_devel" =~ "ruby" ]] && (( $+commands[chruby] )); then
  source /usr/local/opt/chruby/share/chruby/chruby.sh
  chruby ruby-2.3.1
fi
