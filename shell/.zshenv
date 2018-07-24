enable_langs=(python golang node nvm)

# -- AWS -----------------------------------------------------------------------
export AWS_CREDENTIAL_FILE="${HOME}/.aws/credentials"
export AWS_PROFILE="default"
export EC2_REGION="eu-west-1"

# -- K8s -----------------------------------------------------------------------
export KUBECONFIG="${HOME}/.kube/koan.k0"

# -- Language Support ----------------------------------------------------------
if [[ "$enable_langs" =~ "python" ]] && (( $+commands[pyenv] )); then
  export PYENV_ROOT="${HOME}/.pyenv"
  export PATH="${PYENV_ROOT}/bin:${PATH}"
  eval "$(pyenv init -)"
fi

if [[ "$enable_langs" =~ "golang" ]]; then
  PATH="${PATH}:${HOME}/go/bin"
  export GOPATH="${HOME}/go"
fi

if [[ "$enable_langs" =~ "java" ]]; then
  export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_141.jdk/Contents/Home"
  export SDKMAN_DIR="${HOME}/.sdkman"
  [[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]] && source "${HOME}/.sdkman/bin/sdkman-init.sh"
fi

if [[ "$enable_langs" =~ "ruby" ]] && (( $+commands[chruby] )); then
  source /usr/local/opt/chruby/share/chruby/chruby.sh
  chruby ruby-2.3.1
fi

if [[ "$enable_langs" =~ "node" ]]; then
  NPM_PACKAGES="${HOME}/.npm-packages"
  PATH="${PATH}:${NPM_PACKAGES}/bin"
  NODE_PATH="${NPM_PACKAGES}/lib/node_modules:${NODE_PATH}"
fi

if [[ "$enable_langs" =~ "nvm" ]]; then
  [ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"
  source /usr/share/nvm/nvm.sh
  source /usr/share/nvm/install-nvm-exec
fi

if [[ "$enable_langs" =~ "php" ]]; then
  PATH="${PATH}:${HOME}/.composer/vendor/bin"
fi

# -- Misc ----------------------------------------------------------------------
export MC_SKIN=$HOME/.config/mc/solarized.ini
export _Z_DATA=/var/tmp/karelian.z # stfu z
export ANSIBLE_NOCOWS=1
PATH="${PATH}:${HOME}/bin"
. $(which env_parallel.zsh)

# -- Encoding ------------------------------------------------------------------
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_COLLATE="C"
