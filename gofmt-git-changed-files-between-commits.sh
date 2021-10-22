[[ $# -ne 2 ]] && exit 1
for x in `git diff --name-status $1 $2 | grep -v "^D" | egrep "\.go|/$" | awk '{ print $2}'`; do echo "processing $x"; gofmt -w $x; goimports -w $x; done
