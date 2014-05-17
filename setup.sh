#!/usr/bin/env bash

# Ask for root upfront
sudo -v

# Add node.js PPA and install
sudo add-apt-repository --yes ppa:chris-lea/node.js
sudo apt-get update
sudo apt-get install --yes nodejs

# Add git
sudo apt-get install git-core

# Clone the repo
git clone https://github.com/rarescosma/dotfiles.git .dotfiles
cd .dotfiles

npm install
