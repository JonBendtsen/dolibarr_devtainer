#!/bin/bash

set -e
set -o pipefail
source local.config || ( echo "ERROR, create a local.config file from default.config" ; exit 1 )

./10_pull_container_images.sh && \
./20_create_podman_secrets.sh && \
./30_create_podman_pods.sh && \
./42_create_mariadbs.sh && \
./50_create_dolibarrs.sh && \
./60_create_phpmyadmins.sh
