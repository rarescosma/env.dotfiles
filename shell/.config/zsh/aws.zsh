aws_prompt() {
  local _aws_prompt
  if [[ "$AWS_PROFILE" == "default" ]]; then
    _aws_prompt=""
  else
    _aws_prompt="(${AWS_PROFILE}) "
  fi
  echo $_aws_prompt
}
