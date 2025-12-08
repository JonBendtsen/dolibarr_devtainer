#!/bin/bash

set -e
set -o pipefail
source local.config || ( echo "ERROR, create a local.config file from default.config" ; exit 1 )
SRC_CFG="local.config"

./99_start_podman_pods.sh
