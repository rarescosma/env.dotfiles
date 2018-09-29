enable_devel=(kubectl aws python golang node nvm)

# -- Language Support ----------------------------------------------------------
if [[ "$enable_devel" =~ "kubectl" ]]; then
  unset KUBECONFIG
fi

if [[ "$enable_devel" =~ "aws" ]]; then
  export AWS_CREDENTIAL_FILE="${HOME}/.aws/credentials"
  export AWS_PROFILE="default"
  export EC2_REGION="eu-west-1"
  _aws_zsh_completer_path="${HOME}/.local/bin/aws_zsh_completer.sh"
  [ -f "$_aws_zsh_completer_path" ] && source "$_aws_zsh_completer_path"
  unset _aws_zsh_completer_path
fi

if [[ "$enable_devel" =~ "python" ]] && (( $+commands[pyenv] )); then
  export PYENV_ROOT="${HOME}/.pyenv"
  eval "$(pyenv init -)"

  export PIPENV_VENV_IN_PROJECT=1
  export PIPENV_IGNORE_VIRTUALENVS=0
  export PIPENV_HIDE_EMOJIS=1
  export PIPENV_NOSPIN=1
  eval "$(pipenv --completion)"
fi

if [[ "$enable_devel" =~ "golang" ]]; then
  PATH="${PATH}:${HOME}/.golang/bin"
  export GOPATH="${HOME}/.golang"
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
