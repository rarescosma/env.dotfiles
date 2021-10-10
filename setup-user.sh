#!/usr/bin/env bash

set -e
exec 2> >(while read line; do echo -e "\e[01;31m$line\e[0m"; done)

dotfiles_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

stow() {
  if [ -n "$2" ]; then
    target="$HOME/$2"
  else
    target="$HOME"
  fi
  command stow -d "$dotfiles_dir" -t "$target" --no-folding -R "$1"
  echo "stow $dotfiles_dir -> $target / $1"
}

link() {
  orig_file="$dotfiles_dir/$1"
  if [ -n "$2" ]; then
    dest_file="$HOME/$2"
  else
    dest_file="$HOME/$1"
  fi

  mkdir -p "$(dirname "$orig_file")"
  mkdir -p "$(dirname "$dest_file")"

  rm -rf "$dest_file"
  ln -s "$orig_file" "$dest_file"
  echo "$dest_file -> $orig_file"
}

is_chroot() {
  ! cmp -s /proc/1/mountinfo /proc/self/mountinfo
}

systemctl_enable_start() {
  echo "systemctl --user enable --now "$1""
  systemctl --user enable --now "$1"
}

stow::bin() {
  echo "========================"
  echo "Stowing user binaries..."
  echo "========================"

  mkdir -p "$HOME/bin"; stow bin bin

  host_dir="$dotfiles_dir/_nodes/$HOSTNAME"
  if test -d "$host_dir"; then
    echo "========================"
    echo "Stowing node binaries..."
    echo "========================"

    command stow -d "$host_dir" -t "$HOME/bin" --no-folding -R bin
    echo "stow $host_dir -> $HOME/bin / bin"
  fi
}

stow::dotfiles() {
  echo "==========================="
  echo "Setting up user dotfiles..."
  echo "==========================="
  stow devel
  stow gnupg
  stow shell
  stow wm
  stow misc
}

setup::services() {
  echo ""
  echo "================================="
  echo "Enabling and starting services..."
  echo "================================="

  systemctl --user daemon-reload
  systemctl_enable_start "mpd.socket"
  systemctl_enable_start "mpd.service"
  systemctl_enable_start "upmpdcli.service"
  systemctl_enable_start "espanso.service"
}

setup::var() {
  echo ""
  echo "========================================"
  echo "Finishing various user configurations..."
  echo "========================================"

  echo "Customizing firefox css"
  profile=$(grep 'Path=' "$HOME/.mozilla/firefox/profiles.ini" | sed s/^Path=//)
  link "_vendor/firefox-css" ".mozilla/firefox/$profile/chrome"
}

main() {
  stow::bin
  stow::dotfiles

  if is_chroot; then
    echo >&2 "=== Running in chroot, skipping services + var..."
  else
    setup::services
    setup::var
  fi
}

if test -z "${1:-}"; then
  main
else
  for target in "${@}"; do
    $target
  done
fi
