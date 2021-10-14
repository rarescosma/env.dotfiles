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
