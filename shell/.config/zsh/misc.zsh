# -- Ansible -------------------------------------------------------------------
export ANSIBLE_NOCOWS=1

# -- Git Test ------------------------------------------------------------------
export GIT_TEST_VERIFY=true

# -- GNU Parallel --------------------------------------------------------------
if (( $+commands[env_parallel.zsh] )); then
  . $(which env_parallel.zsh)
fi

# -- completion config  --------------------------------------------------------
zstyle ':completion:*:*:*' hosts off      # disable host-based
zstyle ":completion:*:commands" rehash 1  # always rehash
autoload -Uz compinit

# -- Midnight Commander --------------------------------------------------------
export MC_SKIN=$HOME/.config/mc/solarized.ini

# -- Z -------------------------------------------------------------------------
export _Z_DATA=/var/tmp/karelian.z

# -- umask ---------------------------------------------------------------------
umask 002

# -- rehash trap ---------------------------------------------------------------
_usr2_rehash() {
  trap _usr2_rehash USR2
  rehash
}
trap _usr2_rehash USR2

# -- rsync magicka -------------------------------------------------------------
test -f $HOME/bin/ra && source $HOME/bin/ra
rename_partials() {
    for x in $(find ./ -name ".*" -type f | sed -e "s/^\.\///g"); do y=${x%.*}; mv $x ${y#.}; done
}
alias rp=rename_partials

# -- vim katas -----------------------------------------------------------------
alias vimtutor="nvim -c 'Tutor vim-01-beginner'"
surroundtutor() {
  local _tmp=$(mktemp)
  cp ~/sync/areas/vim/surround.practice $_tmp
  i $_tmp
}

# -- ssh-agent -----------------------------------------------------------------
[[ -v enable_ssh_agent ]] || enable_ssh_agent=1

if [[ "$enable_ssh_agent" == "1" ]]; then
  if [ -z "$(pgrep ssh-agent)" ]; then
     /sbin/rm -rf "/tmp/ssh-*" 2>/dev/null
     eval $(ssh-agent -s) > /dev/null
  else
     export SSH_AGENT_PID=$(pgrep ssh-agent)
     export SSH_AUTH_SOCK="$(find /run/user/$(id -u)/ssh-* -name "ssh-agent.*" 2>/dev/null)"
  fi
fi

# -- nix stuff -----------------------------------------------------------------
_locale_archive="${HOME}/.nix-profile/lib/locale/locale-archive"
if (( $+commands[nix-env] )) && test -f "$_locale_archive"; then
  export LOCALE_ARCHIVE="$_locale_archive"
fi

# -- fancy ctrl-z --------------------------------------------------------------
very-fancy-ctrl-z () {
  if [[ $- != *i* ]]; then return; fi     # not interactive, bail
  if fg %1 2>/dev/null; then return; fi   # foreground succeeded, bail

  # line stash/pop mode; credit: https://superuser.com/questions/378018
  if [[ $#BUFFER -eq 0 ]]; then zle redisplay; else zle push-input; fi
}
zle -N very-fancy-ctrl-z
bindkey '^Z' very-fancy-ctrl-z

# -- vim cmd edit --------------------------------------------------------------
autoload edit-command-line; zle -N edit-command-line
bindkey "^[v" edit-command-line
WORDCHARS=${WORDCHARS/\/}

# -- no history for you! -------------------------------------------------------
alias disablehistory="function zshaddhistory() {  return 1 }"

# -- download entire playlist --------------------------------------------------
alias yt-dlpl="yt-dlp --format 'bestvideo[height<=?1080][vcodec!^=vp]+bestaudio' --yes-playlist -o '%(playlist_index)02d - %(title)s.%(ext)s'"

# -- switch current vault ------------------------------------------------------
scv() {
  local vault
  vault="$(fd -t d --base-directory "$VAULT_ROOT" --exact-depth 1 \
    | fzf_cmd --query "$*" | sed 's/\/$//g')"
  test -z "$vault" && return

  echo "Switching to the $vault vault"

  rm -f $VAULT_ROOT/current && ln -sf $VAULT_ROOT/$vault $VAULT_ROOT/current
}
