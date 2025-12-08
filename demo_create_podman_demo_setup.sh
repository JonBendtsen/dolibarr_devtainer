#!/bin/bash

set -e
set -o pipefail
source demo.config || ( echo "ERROR, create a demo.config file from default.config" ; exit 1 )

ACTIVE_VERSIONS="${DEMO_VERSIONS}"
SRC_CFG="demo.config"

./10_pull_container_images.sh ${SRC_CFG} && \
./20_create_podman_secrets.sh ${SRC_CFG} && \
./30_create_podman_pods.sh ${SRC_CFG} && \
./42_create_mariadbs.sh ${SRC_CFG} && \
./50_create_dolibarrs.sh ${SRC_CFG} && \
./60_create_phpmyadmins.sh ${SRC_CFG}
