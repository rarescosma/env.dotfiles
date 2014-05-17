#!/usr/bin/env bash

# Ask for root upfront
sudo -v

# Add node.js PPA and install node and git
sudo add-apt-repository --yes ppa:chris-lea/node.js
sudo apt-get update
sudo apt-get install --yes git-core nodejs

# Install grunt cli globally
sudo npm install -g grunt-cli

# Clone the repo
git clone https://github.com/rarescosma/dotfiles.git dot
cd dot
git checkout grunt

# For some reason the local tmp folder gets mangled up
sudo rm -rf ~/tmp
npm install

clear
grunt
