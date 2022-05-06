#!/bin/bash

set -x
set -e

target="$HOME/Documents/private/"

cd "$target"

cp -f /etc/hosts "$target/etc-hosts"

[ ! -e "$target/home" ] && mkdir "$target/home"
cp -rf ~/.bash_profile "$target/home"
cp -rf ~/.ssh "$target/home"
cp -rf ~/.zshrc "$target/home"
cp -rf ~/.gitconfig "$target/home"
cp -rf ~/.kube "$target/home"

if [[ $(git status --porcelain=v1 2>/dev/null | wc -l) -eq 0 ]]
then
    echo "No new content to commit"
    exit 0
else
    git add .
    git commit -s -m "daily backup"
    git push
fi

