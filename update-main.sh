#!/usr/bin/env bash
set -e

IMMUS=""

_stash_arch_packs() {
    git update-index --no-assume-unchanged _arch/package*
    git stash || true
}

_unchange_arch_packs() {
    git update-index --assume-unchanged _arch/package*
}

_restore_immus() {
    test -z "$IMMUS" && return
    while IFS= read -r line; do
        test -n "$line" && sudo chattr +i "$line"
    done <<< "$IMMUS"
}

_rebase_pre() {
    _stash_arch_packs
    IMMUS="$(lsattr -laR . 2>/dev/null | grep Immutable | sed -e 's#\s*Immutable$##g')"
    test -z "$IMMUS" && return
    while IFS= read -r line; do
        test -n "$line" && sudo chattr -i "$line"
    done <<< "$IMMUS"
}

_rebase_post() {
    _unchange_arch_packs
    _restore_immus
}

rebase() {
    _rebase_pre
    # move current host customizations as the last commit
    GIT_SEQUENCE_EDITOR=./bin/git-local-last git rebase -i main || _restore_immus
    _rebase_post
}

push_main() {
    # move local main one behind
    git branch -f main HEAD~1

    # update origin
    git push origin main:main $*
}

if [[ "$@" != "" ]]; then
    $@
else
    rebase
    push_main
fi

