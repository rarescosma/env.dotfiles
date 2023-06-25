if test -d "$ZSH/custom/plugins/nix-shell"; then
    plugins+=(nix-shell)
fi
if test -d "$ZSH/custom/plugins/nix-zsh-completions"; then
    plugins+=(nix-zsh-completions)
fi

prompt_nix_shell() {
  if [[ -n "$IN_NIX_SHELL" ]]; then
    if [[ -n $NIX_SHELL_PACKAGES ]]; then
      local package_names=""
      local packages=($NIX_SHELL_PACKAGES)
      for package in $packages; do
        package_names+=" ${package##*.}"
      done
      echo "{$package_names } "
    elif [[ -n $name ]]; then
      local cleanName=${name#interactive-}
      cleanName=${cleanName#lorri-keep-env-hack-}
      cleanName=${cleanName%-environment}
      echo "{ $cleanName } "
    else # This case is only reached if the nix-shell plugin isn't installed or failed in some way
      echo "nix-shell {} "
    fi
  fi
}

