#!/bin/bash

set -x
set -e

cd /etc/kubesphere
rm -rf kubesphere.yaml ingress-controller
kcm=$(kubectl -n kubesphere-system get pod -l app=ks-apiserver -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n kubesphere-system $kcm -- tar cfh - ./  -C /etc/kubesphere | tar xf -

