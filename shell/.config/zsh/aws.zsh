prompt_aws() {
  local _aws_prompt
  _aws_prompt=""
  if test -n "$AWS_PROFILE" && [[ "$AWS_PROFILE" != "default" ]]; then
    _aws_prompt="[${AWS_PROFILE}] "
  fi
  echo "$_aws_prompt"
}

# change the AWS profile
awc() {
  local profile maybe_kubeconfig
  profile="$(cat $AWS_SHARED_CREDENTIALS_FILE | grep -o '\[[^]]*\]' | tr -d '[]' | fzf_cmd --query "$*")"
  test -z "$profile" && return

  maybe_kubeconfig="${HOME}/.kube/${profile}"

  if test -f "${maybe_kubeconfig}"; then
    export KUBECONFIG="${HOME}/.kube/${profile}"
    export CLUSTER="${profile}"
    touch "${HOME}/.kube"
  fi

  export AWS_PROFILE="${profile}"
}
