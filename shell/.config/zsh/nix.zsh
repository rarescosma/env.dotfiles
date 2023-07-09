prompt_nix_shell() {
  local prompt=""
  test -n "$_NIX_PROMPT" && prompt="$_NIX_PROMPT"
  test -n "$VIRTUAL_ENV" && prompt="$prompt 🐍"
  test -n "$prompt" && echo "$prompt "
}

# while this is open: https://github.com/direnv/direnv/issues/443
# we have to make due with the below curse to force zsh
# to load all the custom site-functions of nix packages
_fpath_orig=("${fpath[@]}")

_nix_fpath_hook() {
    local nix_fpath
    if [[ -n "$_NIX_FPATH" ]] && [[ "$fpath" == "$_fpath_orig" ]]; then
        # turn ":"-separated string into array
        nix_fpath=("${(@s/:/)_NIX_FPATH}")
        
        # prepend it to fpath and reload completions
        fpath=( "${nix_fpath[@]}" "${fpath[@]}" )
        compinit -u
    fi
    if [[ -z "$_NIX_FPATH" ]] && [[ "$fpath" != "$_fpath_orig" ]]; then
        fpath=( "${_fpath_orig[@]}" )
    fi
}
typeset -ag precmd_functions;
if [[ -z "${precmd_functions[(r)_nix_fpath_hook]+1}" ]]; then
  precmd_functions=( _nix_fpath_hook ${precmd_functions[@]} )
fi

if type direnv >/dev/null; then
  _evalcache direnv hook zsh

  test -n "$(declare -f "_direnv_hook")" || return
  eval "${_/_direnv_hook/_direnv_hook_orig}"

  _direnv_hook() {
    _direnv_hook_orig "$@" 2> >(egrep -v '^direnv: (export)')
    wait
  }
fi

function meltdown() {
    bash -c "cd $HOME/src; source $XDG_CONFIG_HOME/direnv/direnvrc; _nix_clean_old_gcroots .direnv"

    if [[ "$@" == "gc" ]]; then nix-collect-garbage; fi

    local _pwd="$(pwd)"; 
    cd $HOME/src 
    touch .envrc && nix-direnv-reload && touch --date=@0 .envrc
    cd "$_pwd"
}
