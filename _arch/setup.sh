#!/usr/bin/env bash

set -e

PACKAGE_GROUPS="base-devel xorg"

pac::list_aur() {
  pacman -Qqm | sort
}

pac::list_non_group() {
  # packages from groups
  comm -23 <(pacman -Qqe | sort | grep -v "firmware") <({ pacman -Qqg $PACKAGE_GROUPS; expac -l '\n' '%E' base; } | sort | uniq)
}

pac::list_non_group_non_aur() {
  comm -23 <(pac::list_non_group) <(pac::list_aur)
}

pac::diff() {
  local dot other packs new_packs removed added
  dot="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  other="${1}"
  shift

  packs=$( { cat "${dot}/packages"; cat "${dot}/packages.aur"; } | sort | uniq )
  new_packs=$( { cat "${other}/packages"; cat "${other}/packages.aur"; } | sort | uniq )

  removed=$( comm -23 <(echo "${packs}") <(echo "${new_packs}") | tr "\n" " " )
  added=$( comm -13 <(echo "${packs}") <(echo "${new_packs}") | tr "\n" " " )

  if [ ! -z "${added}" ]; then
    printf ">> Found new packages:\n${added}\n"
    read -p "<< Press any key to install them."
    paru -Sy $added
  fi

  if [ ! -z "${removed}" ]; then
    printf ">> Packages removed on remote:\n${removed}\n"
    read -p "<< Press any key to remove them."
    sudo pacman -Rns --noconfirm $removed
  fi
}

pac::list() {
  local output_dir
  output_dir="${1:-./}"
  echo $PACKAGE_GROUPS | tr " " "\n" > "$output_dir/package.groups"
  pac::list_non_group_non_aur > "$output_dir/packages"
  pac::list_aur > "$output_dir/packages.aur"
}

_completion() {
  local fun_list=$(declare -F | cut -d ' ' -f3 | grep "^[^_]" | xargs)
  cat <<EOF
_completion() {
  if (( \$COMP_CWORD < 2 )); then
    COMPREPLY=( \$(compgen -W "${fun_list}" -- "\${COMP_WORDS[COMP_CWORD]}") )
  else
    COMPREPLY=""
  fi
  return 0
}

complete -F _completion $(basename $0)
EOF
}

# Dispatch
"$@"
