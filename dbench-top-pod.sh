#!/bin/bash

set -x
set -e

limit="$1"
count=0

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
log="/root/rook-ceph-workload-test/top-pod-$timestamp.log"

while [[ $count -le $limit ]]
do
    pvccount=$(kubectl get pvc -A | { grep -c "rook-ceph" || true; } )
    echo "$(date) number of rook ceph pvc: ${pvccount}" >> $log
    kubectl get pvc -A | { grep "rook-ceph" >> $log || true; }
    kubectl get pod >> $log
    running=$(kubectl get pod | grep "dbench-large-test" | { egrep -i -c "running" || true; } )
    echo "number of running pod: $running" >> $log
    kubectl -n rook-ceph top pod >> $log
    sed "s/test/test-$count/g" dbench-large-test.yaml > dbench-large-test-$count.yaml 
    kubectl apply -f dbench-large-test-$count.yaml 
    sleep 60
    let count=count+1
done
