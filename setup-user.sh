#!/usr/bin/env bash

set -e
exec 2> >(while read line; do echo -e "\e[01;31m$line\e[0m"; done)

dotfiles_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

_host() {
  set +e
  if test -f /etc/hostname; then
    head -1 /etc/hostname
  elif command -v hostname &>/dev/null; then
    hostname | cut -d- -f1
  fi
  set -e
}

stow() {
  if [ -n "$2" ]; then
    target="$HOME/$2"
  else
    target="$HOME"
  fi
  command stow -d "$dotfiles_dir" -t "$target" --no-folding -R "$1"
  echo "stow $dotfiles_dir -> $target / $1"
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

  host_dir="$dotfiles_dir/_nodes/$(_host)"
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
  mkdir -p "${HOME}/.local/state/mpd"
  systemctl_enable_start "mpd@pulse.service"
  systemctl_enable_start "upmpdcli.service"
  systemctl_enable_start "mpDris2.service" || true
  systemctl_enable_start "ssh-agent.service"
  systemctl_enable_start "i3-startup.service"
}

main() {
  stow::bin
  stow::dotfiles

  if is_chroot; then
    echo >&2 "=== Running in chroot, skipping services..."
  else
    setup::services
  fi
}

if test -z "${1:-}"; then
  main
else
  for instr in "${@}"; do
    $instr
  done
fi
