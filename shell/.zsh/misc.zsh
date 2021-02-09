# -- Ansible -------------------------------------------------------------------
export ANSIBLE_NOCOWS=1

# -- Git Test ------------------------------------------------------------------
export GIT_TEST_VERIFY=true

# -- GNU Parallel --------------------------------------------------------------
if (( $+commands[env_parallel.zsh] )); then
  . $(which env_parallel.zsh)
fi

# -- Midnight Commander --------------------------------------------------------
export MC_SKIN=$HOME/.config/mc/solarized.ini
alias mc='LANG=en_US mc --nosubshell'

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
