_join_by() {
  local IFS="$1"
  shift
  echo "$*"
}

alias k='kubectl'

if command -v kubectl >/dev/null 2>&1; then
  _evalcache kubectl completion zsh
fi

ksn() {
  local ns
  ns=$(kubectl get namespaces --no-headers | sort | fzf_cmd --query "$*" | tr -s ' ' | cut -d' ' -f1)
  [ ! -z "$ns" ] && {
    kubectl config set-context "$(kubectl config current-context)" --namespace="$ns"
    export KNS="$ns"
  }
}

ksc() {
  local kube_dir configs config
  kube_dir="${HOME}/.kube"
  config="$1"

  if ! test -f "${kube_dir}/${config}"; then
    configs=($(find "$kube_dir" -maxdepth 1 ! -type d | grep -v "/config$" | grep -v "cache"))
    if test -n "$CK8S_CONFIG_PATH"; then
        configs+=($(find "$CK8S_CONFIG_PATH/.state" -maxdepth 1 ! -type d | grep "kube_config"))
    fi

    for ((i=1; i <= ${#configs}; i++)); do
      configs[i]="${configs[i]/#${HOME}/~}"
    done

    config="$(_join_by $'\n' "${configs[@]}" \
    | sort | uniq \
    | fzf_cmd --query "$*")"
  fi

  test -z "$config" && return

  export KUBECONFIG="${config/#\~/$HOME}"
  touch "$kube_dir"
  export CLUSTER="${config}"
  export KUBE_PS1_ENABLED=on
}

kse() {
  local ck8s_dir configs config kubeconfig
  ck8s_dir="${HOME}/.ck8s"
  config="$1"

  if ! test -f "${ck8s_dir}/${config}"; then
    configs=($(find "$ck8s_dir" -mindepth 1 -maxdepth 1 -type d | grep -vE ".ck8s/_|\.idea"))

    for ((i=1; i <= ${#configs}; i++)); do
      configs[i]="${configs[i]/#${HOME}/~}"
    done

    config="$(_join_by $'\n' "${configs[@]}" \
    | sort | uniq \
    | fzf_cmd --query "$*")"
  fi

  test -z "$config" && return

  export CK8S_CONFIG_PATH="${config/#\~/$HOME}"

  if test -f "${CK8S_CONFIG_PATH}/.state/kube_config_mc.yaml"; then
      kubeconfig="${CK8S_CONFIG_PATH}/.state/kube_config_mc.yaml"
  elif test -f "${CK8S_CONFIG_PATH}/.state/kube_config_sc.yaml"; then
      kubeconfig="${CK8S_CONFIG_PATH}/.state/kube_config_sc.yaml"
  fi

  test -z "$kubeconfig" && {
      unset KUBECONFIG
      return
  }

  export KUBECONFIG="${kubeconfig}"

  touch "${HOME}/.kube"
  export KUBE_PS1_ENABLED=on
}

