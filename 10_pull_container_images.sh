#!/bin/bash

set -e
set -o pipefail
source local.config || ( echo "ERROR, create a local.config file from default.config" ; exit 1 )

podman pull phpmyadmin
podman pull mariadb:latest

for VERSION in ${ACTIVE_VERSIONS}; do
    IMAGE_VERSION="$( echo ${VERSION} | cut -d"." -f1)"
    podman pull docker.io/dolibarr/dolibarr:${IMAGE_VERSION} || continue
done
