# -- Ansible -------------------------------------------------------------------
export ANSIBLE_NOCOWS=1

# -- Git Test ------------------------------------------------------------------
export GIT_TEST_VERIFY=true

# -- GNU Parallel --------------------------------------------------------------
. $(which env_parallel.zsh)

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
