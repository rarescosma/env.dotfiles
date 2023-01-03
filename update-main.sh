#!/usr/bin/env bash

# move current host customizations as the last commit
GIT_SEQUENCE_EDITOR=./bin/git-local-last git rebase -i main

# move local main one behind
git branch -f main HEAD~1

# update origin
git push origin main:main

