#!/bin/bash

# bootstrap $HOME
cp -r --update=none /opt/ling110/home-skeleton/. "$HOME/"
mkdir -p $HOME/assignments

# git configuration
git config --global core.excludesFile "$HOME/.gitignore"
gh auth setup-git --hostname github.com --force
