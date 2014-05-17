#!/usr/bin/env bash

# Add node.js PPA and install
sudo add-apt-repository --yes ppa:chris-lea/node.js
sudo apt-get update
sudo apt-get install --yes nodejs

which npm