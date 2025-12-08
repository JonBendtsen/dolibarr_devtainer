#!/bin/bash
SRC_CFG="$1"

set -e
set -o pipefail
source ${SRC_CFG}

podman pull phpmyadmin
podman pull mariadb:latest

for VERSION in ${ACTIVE_VERSIONS}; do
    IMAGE_VERSION="$( echo ${VERSION} | cut -d"." -f1)"
    podman image exists docker.io/dolibarr/dolibarr:${IMAGE_VERSION} || \
            podman pull docker.io/dolibarr/dolibarr:${IMAGE_VERSION}
done
