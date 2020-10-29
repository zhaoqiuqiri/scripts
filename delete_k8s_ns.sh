#!/bin/bash
set -x

[[ $# -eq 0 ]] && echo "usage: $0 <namespace keyword>" && exit 1
KEY=$1

for rs in $(kubectl get ns -o name | grep "$KEY" | cut -d '/' -f2,2)
do
  kubectl -n $rs delete pod --all
  kubectl -n $rs delete pvc --all
  kubectl -n $rs delete volumesnapshots --all
done

sleep 1

for rs in $(kubectl get volumesnapshotcontents.snapshot.storage.k8s.io | grep "$KEY" | awk '{print $1}')
do
  kubectl delete volumesnapshotcontents.snapshot.storage.k8s.io $rs
done

sleep 1

for pv in $(kubectl get pv | grep "$KEY" | awk '{print $1}')
do
  kubectl delete pv $pv
done

sleep 1

for rs in $(kubectl get ns -o name | grep "$KEY")
do
  kubectl delete $rs
done

sleep 1

for i in $(kubectl get volumesnapshotclasses.snapshot.storage.k8s.io -o name | grep "$KEY")
do
  kubectl delete $i
done

sleep 1

for i in $(kubectl get sc -o name | grep "$KEY")
do
  kubectl delete $i
done