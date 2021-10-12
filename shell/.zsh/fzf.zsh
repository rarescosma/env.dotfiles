export FZF_DEFAULT_OPTS="--exact --extended --cycle --reverse --bind change:top --bind ctrl-e:accept --expect=enter"
export FZF_CTRL_T_COMMAND="fd --type file --follow --hidden --exclude .git"

PATH="$PATH:$_VENDOR/fzf/bin"
source "$_VENDOR/fzf/shell/key-bindings.zsh"

## wrapper for fzf to allow partial queries
fzf_cmd() {
  # Drop empty queries
  local q fzf_bin
  q=$(echo "$*" | sed -e 's/\(.*\)--query \(.*\)/\2/g')
  if [[ -z $FZF_TMUX ]]; then
    fzf_bin="fzf"
  else
    fzf_bin="fzf-tmux"
  fi

  if [[ -z $q ]]; then
    cat | $fzf_bin --multi | tail -n +2
  else
    cat | grep -i "$q" | $fzf_bin -1 $* | tail -n +2
  fi
}
