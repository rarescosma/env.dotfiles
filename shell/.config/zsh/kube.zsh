_join_by() {
  local IFS="$1"
  shift
  echo "$*"
}

alias k='kubectl'

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

    for ((i=1; i <= ${#configs}; i++)); do
      configs[i]="${configs[i]/$kube_dir\/}"
    done

    config="$(_join_by $'\n' "${configs[@]}" \
    | sort | uniq \
    | fzf_cmd --query "$*")"
  fi

  test -z "$config" && return

  export KUBECONFIG="${kube_dir}/${config}"
  touch "$kube_dir"
  export CLUSTER="${config}"
  export KUBE_PS1_ENABLED=on
}

