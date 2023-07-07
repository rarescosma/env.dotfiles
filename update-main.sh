#!/usr/bin/env bash
set -e

stash_arch_packs() {
    git update-index --no-assume-unchanged _arch/package*
    git stash
}

unchange_arch_packs() {
    git update-index --assume-unchanged _arch/package*
}

rebase() {
    stash_arch_packs
    # move current host customizations as the last commit
    GIT_SEQUENCE_EDITOR=./bin/git-local-last git rebase -i main
    unchange_arch_packs
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

