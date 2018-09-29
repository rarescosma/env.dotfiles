PATH="$PATH:$_VENDOR/fzf/bin"
source "$_VENDOR/fzf/shell/key-bindings.zsh"

## wrapper for fzf to allow partial queries
fzf_cmd() {
  # Drop empty queries
  local q
  q=$(echo "$*" | sed -e 's/\(.*\)--query \(.*\)/\2/g')

  if [[ -z $q ]]; then
    cat | fzf-tmux --multi | tail -n +2
  else
    cat | grep -i "$q" | fzf-tmux -1 $* | tail -n +2
  fi
}
