prompt_nix_shell() {
  if [[ -n "$_NIX_PROMPT" ]]; then
    echo "{$_NIX_PROMPT} "
  fi
}

if test -f "$HOME/.nix-profile/lib/locale/locale-archive"; then
    export LOCALE_ARCHIVE="$HOME/.nix-profile/lib/locale/locale-archive"
fi

if type direnv >/dev/null; then
    _evalcache direnv hook zsh
fi
