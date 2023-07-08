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
