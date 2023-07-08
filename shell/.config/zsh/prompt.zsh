#  git_prompt_info overrides
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %{$fg[red]%}?"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}!"
ZSH_THEME_GIT_PROMPT_CLEAN=""

KUBE_PS1_SYMBOL_ENABLE=false
KUBE_PS1_SUFFIX=") "
KUBE_PS1_DIVIDER="%{$fg[green]%}/%{$reset_color%}"
KUBE_PS1_CTX_COLOR="green"
KUBE_PS1_NS_COLOR="green"
KUBE_PS1_PREFIX_COLOR="green"
KUBE_PS1_SUFFIX_COLOR="green"

PROMPT='%{$fg[magenta]%}@%m%{$reset_color%} $(prompt_nix_shell)\
%{$fg[yellow]%}$(prompt_aws)%{$reset_color%}%{$fg[green]%}$(kube_ps1)%{$fg[blue]%}%~%{$fg[default]%} $(git_prompt_info)
%130(?..%(?..[%{$fg[red]%}%?%{$reset_color%}] ))%{$reset_color%}# '
