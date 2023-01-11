# -- Ansible -------------------------------------------------------------------
export ANSIBLE_NOCOWS=1

# -- Git Test ------------------------------------------------------------------
export GIT_TEST_VERIFY=true

# -- GNU Parallel --------------------------------------------------------------
if (( $+commands[env_parallel.zsh] )); then
  . $(which env_parallel.zsh)
fi

# -- disable hosts completion --------------------------------------------------
zstyle ':completion:*:*:*' hosts off

# -- moc config ----------------------------------------------------------------
alias mocp="mocp -O MOCDir=${XDG_CONFIG_HOME}/moc"

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
  cp ~/Dropbox/areas/vim/surround.practice $_tmp
  i $_tmp
}

# -- ssh-agent -----------------------------------------------------------------
if [ -z "$(pgrep ssh-agent)" ]; then
   /sbin/rm -rf /tmp/ssh-* 2>/dev/null
   eval $(ssh-agent -s) > /dev/null
else
   export SSH_AGENT_PID=$(pgrep ssh-agent)
   export SSH_AUTH_SOCK="$(find /run/user/$(id -u)/ssh-* -name "ssh-agent.*" 2>/dev/null)"
fi
