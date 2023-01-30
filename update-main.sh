#!/usr/bin/env bash
set -e

rebase() {
    # move current host customizations as the last commit
    GIT_SEQUENCE_EDITOR=./bin/git-local-last git rebase -i main
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

