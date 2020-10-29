set -x
git fetch upstream && git checkout master && git rebase upstream/master
