source "$_VENDOR/zsh-kubectl-prompt/kubectl.zsh"

#  git_prompt_info overrides
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %{$fg[red]%}?"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}!"
ZSH_THEME_GIT_PROMPT_CLEAN=""

CURRENT_BG='NONE'
_prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

PROMPT='%{$fg[magenta]%}@%m%{$reset_color%}\
$(prompt_aws)%{$reset_color%}%{$fg[green]%}$ZSH_KUBECTL_PROMPT%{$fg[blue]%}%~%{$fg[default]%} $(git_prompt_info)
%130(?..%(?..[%{$fg[red]%}%?%{$reset_color%}] ))%{$reset_color%}# '
