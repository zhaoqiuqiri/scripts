for x in `git status -s | grep -v "^D" | egrep "\.go|/$" | awk '{ print $2}'`; do echo "processing $x"; gofmt -w $x; goimports -w $x; done
