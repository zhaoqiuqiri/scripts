#!/bin/bash
set -e

# arguments: <image-with-tag>
function image-exists {
    docker manifest inspect "$1" > /dev/null
    echo $?
}

function usage {
    echo "Usage: <$0> <image-map-file> <operation>"
    echo "Image map file contains a list of source image to dockerhub image item"
    echo "example:"
    echo "k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.0.1 -> csistorage/csi-node-driver-registrar:v2.0.1"
    echo "Operation:"
    echo "push: pull source images(usually from non-docker registries), retag them and push them to dockerhub"
    echo "pull: pull images from dockerhub and retag them"
}

if [[ $# -lt 2 ]]
then
    usage
    exit 1
fi

images="$1"
op="$2"

if [[ "$op" == "push" ]]
then
    while read -r map
    do
        echo "Processing $map"
        image=$(echo "$map" | awk -F '->' '{print $1}' | tr -d ' ')
        docker_image=$(echo "$map" | awk -F '->' '{print $2}' | tr -d ' ')
        [[ $(image-exists "$docker_image") -eq 0 ]] && echo "$docker_image already exists" && continue
        docker pull "$image"
        docker tag "$image" "$docker_image"
        docker push "$docker_image"
    done < "$images"
elif [[ "$op" == "pull" ]]
then
    while read -r map
    do
        echo "Processing $map"
        image=$(echo "$map" | awk -F '->' '{print $1}' | tr -d ' ')
        docker_image=$(echo "$map" | awk -F '->' '{print $2}' | tr -d ' ')
        docker pull "$docker_image"
        docker tag "$docker_image" "image"
    done < "$images"
else
    usage
    exit 1
fi
  