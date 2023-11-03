#!/usr/bin/env bash

copy() {
  _copy_from "$dotfiles_dir/_arch" $@
}

copy_host() {
  _copy_from "$dotfiles_dir/_nodes/$HOSTNAME" $@
}

_copy_from() {
  local root
  root="$1"
  shift

  if [ -z "$1" ]; then
    echo "you might have forgotten to quote some args, I'm not removing /"
    exit 1
  fi

  if [ -z "$reverse" ]; then
    orig_file="$root/$1"
    dest_file="/$1"
  else
    orig_file="/$1"
    dest_file="$root/$1"
  fi

  mkdir -p "$(dirname "$orig_file")"
  mkdir -p "$(dirname "$dest_file")"

  rm -rf "$dest_file"

  cp -R "$orig_file" "$dest_file"
  if [ -z "$reverse" ]; then
    [ -n "$2" ] && chmod "$2" "$dest_file"
  else
    chown -R karelian "$dest_file"
  fi
  echo "$dest_file <= $orig_file"
}

link() {
  orig_file="$dotfiles_dir/_arch/$1"
  if [ -n "$2" ]; then
    dest_file="/$2"
  else
    dest_file="/$1"
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
  echo "systemctl enable --now "$1""
  systemctl enable "$1"
  systemctl start "$1"
}
