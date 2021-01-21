#!/bin/bash

#!/bin/bash

set -x
set -e

cd /Users/qc/go/src/kubesphere.io/kubesphere
rm -rf kubesphere.yaml tmp/k8s-webhook-server/serving-certs
kcm=$(kubectl -n kubesphere-system get pod -l app=ks-controller-manager -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n kubesphere-system $kcm -- tar cfh - "kubesphere.yaml" -C /etc/kubesphere | tar xf -
kubectl exec -n kubesphere-system $kcm -- tar cfh - "/tmp/k8s-webhook-server/serving-certs" | tar xf -

