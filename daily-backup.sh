#!/bin/bash

set -x
set -e

target="$HOME/Documents/private/"

cd "$target"

cp -f /etc/hosts "$target/etc-hosts"
cp -f ~/.bash_profile "$target/bash_profile"

if [[ $(git status --porcelain=v1 2>/dev/null | wc -l) -eq 0 ]]
then
    echo "No new content to commit"
    exit 0
else
    git add .
    git commit -s -m "daily backup"
    git push
fi

