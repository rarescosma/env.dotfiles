prompt_nix_shell() {
  local prompt=""
  test -n "$_NIX_PROMPT" && prompt="$_NIX_PROMPT"
  test -n "$VIRTUAL_ENV" && prompt="$prompt 🐍"
  test -n "$prompt" && echo "$prompt "
}

if test -f "$HOME/.nix-profile/lib/locale/locale-archive"; then
    export LOCALE_ARCHIVE="$HOME/.nix-profile/lib/locale/locale-archive"
fi

if type direnv >/dev/null; then
    _evalcache direnv hook zsh
fi

function meltdown() {
    bash -c "cd $HOME/src; source $XDG_CONFIG_HOME/direnv/direnvrc; _nix_clean_old_gcroots .direnv"

    if [[ "$@" == "gc" ]]; then nix-collect-garbage; fi

    local _pwd="$(pwd)"; 
    cd $HOME/src 
    touch .envrc && nix-direnv-reload && touch --date=@0 .envrc
    cd "$_pwd"
}
