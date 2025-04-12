#!/bin/bash

set -e
set -o pipefail
source local.config || ( echo "ERROR, create a local.config file from default.config" ; exit 1 )

for VERSION in ${ACTIVE_VERSIONS}; do
	PODNAME="${POD_BASENAME}_${VERSION}"
	podman pod start "${PODNAME}"
done
