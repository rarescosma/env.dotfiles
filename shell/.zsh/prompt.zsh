source "$_VENDOR/zsh-kubectl-prompt/kubectl.zsh"

#  git_prompt_info overrides
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %{$fg[red]%}?"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}!"
ZSH_THEME_GIT_PROMPT_CLEAN=""

PROMPT='%{$fg[magenta]%}@%m%{$reset_color%} \
%{$fg[cyan]%}$ZSH_KUBECTL_PROMPT%{$fg[blue]%}%~%{$fg[default]%} $(git_prompt_info)
%130(?..%(?..[%{$fg[red]%}%?%{$reset_color%}] ))%{$reset_color%}> '
