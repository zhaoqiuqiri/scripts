#!/bin/bash
# given pod name and namespace, retrieve its image list and map it to dcokerhub csistorage repo
[[ $# -ne 2 ]] && echo "usage: <$0> <pod> <namespace>" && exit 1

pod="$1"
ns="$2"
repo="csistorage"

while read -r image
do
    name=$(echo "$image" | awk -F '/' '{print $NF}')
    echo "$image -> $repo/$name"
done < <(kubectl get pod "$pod" -n "$ns" -o yaml | grep " image:" | sed 's/- image/image/g' | awk '{print $2}' | sort | uniq)