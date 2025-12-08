#!/bin/bash

SRC_CFG="$1"

set -e
set -o pipefail
source ${SRC_CFG}

for VERSION in ${ACTIVE_VERSIONS}; do
	PODNAME="${POD_BASENAME}_${VERSION}"
	podman pod start "${PODNAME}"
done
