#  git_prompt_info overrides
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %{$fg[red]%}?"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}!"
ZSH_THEME_GIT_PROMPT_CLEAN=""

export KUBE_PS1_ENABLED=off
KUBE_PS1_SYMBOL_ENABLE=false
KUBE_PS1_SUFFIX=") "
KUBE_PS1_DIVIDER="%{$fg[green]%}/%{$reset_color%}"
KUBE_PS1_CTX_COLOR="green"
KUBE_PS1_NS_COLOR="green"
KUBE_PS1_PREFIX_COLOR="green"
KUBE_PS1_SUFFIX_COLOR="green"

__current_vault() {
  local vault
  test -s "${VAULT_DIR}" || return 0
  vault="$(readlink -f "${VAULT_DIR}")"
  print -r -- "[v:${vault##*/}] "
}

PROMPT='%{$fg[magenta]%}@%m%{$reset_color%} \
%{$fg[yellow]%}$(prompt_aws)%{$reset_color%}%{$fg[green]%}$(kube_ps1)%{$fg[cyan]%}$(__current_vault)%{$fg[blue]%}%~%{$fg[default]%} $(git_prompt_info)
%130(?..%(?..[%{$fg[red]%}%?%{$reset_color%}] ))%{$reset_color%}# '
