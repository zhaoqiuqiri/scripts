set -x
current=$(git branch --show-current)
master=master
git rev-parse --verify "$master"
[[ $? -eq 0 ]] || master="main" 
git fetch upstream && git checkout "$master" && git rebase upstream/"$master" && git checkout "$current"
