#!/bin/bash
# pull and tag images for neonsan csi e2e test
set -e
set -x

docker pull stoneshiyunify/csi-neonsan-ubuntu:canary
docker tag stoneshiyunify/csi-neonsan-ubuntu:canary csiplugin/csi-neonsan-ubuntu:canary

docker pull stoneshiyunify/csi-neonsan:canary
docker tag stoneshiyunify/csi-neonsan:canary csiplugin/csi-neonsan:canary

docker pull kubetesting/agnhost:2.12
docker tag kubetesting/agnhost:2.12 us.gcr.io/k8s-artifacts-prod/e2e-test-images/agnhost:2.12

docker pull gcr.azk8s.cn/kubernetes-e2e-test-images/mounttest:1.0
docker tag gcr.azk8s.cn/kubernetes-e2e-test-images/mounttest:1.0 gcr.io/kubernetes-e2e-test-images/mounttest:1.0

docker pull quay.azk8s.cn/k8scsi/csi-provisioner:v1.5.0
docker tag quay.azk8s.cn/k8scsi/csi-provisioner:v1.5.0 csiplugin/csi-provisioner:v1.5.0

docker pull quay.azk8s.cn/k8scsi/csi-attacher:v2.1.1
docker tag quay.azk8s.cn/k8scsi/csi-attacher:v2.1.1 csiplugin/csi-attacher:v2.1.1

docker pull quay.azk8s.cn/k8scsi/csi-resizer:v0.5.1
docker tag quay.azk8s.cn/k8scsi/csi-resizer:v0.5.1 csiplugin/csi-resizer:v0.5.1

docker pull quay.azk8s.cn/k8scsi/csi-snapshotter:v2.0.1
docker tag quay.azk8s.cn/k8scsi/csi-snapshotter:v2.0.1 csiplugin/csi-snapshotter:v2.0.1

docker pull quay.azk8s.cn/k8scsi/csi-node-driver-registrar:v1.2.0
docker tag quay.azk8s.cn/k8scsi/csi-node-driver-registrar:v1.2.0 csiplugin/csi-node-driver-registrar:v1.2.0