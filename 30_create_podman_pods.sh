#!/bin/bash

set -e
set -o pipefail
source local.config || ( echo "ERROR, create a local.config file from default.config" ; exit 1 )

function create_pod {
	IMAGE_VERSION=$1
	if [[ "develop" == "${IMAGE_VERSION}" ]]; then
		PORTNUMBER_BASE=100
	else
		PORTNUMBER_BASE=$( echo "${IMAGE_VERSION}" | tr -c -d "[:digit:]" )
	fi
	PODNAME="${POD_BASENAME}_${IMAGE_VERSION}"
	podman pod exists "${PODNAME}" || podman pod create \
		--publish 127.0.0.1:${PORTNUMBER_BASE}36:${PORTNUMBER_BASE}36	\
		--publish 127.0.0.1:${PORTNUMBER_BASE}80:80	\
		--publish 127.0.0.1:${PORTNUMBER_BASE}81:81	\
		--publish 127.0.0.1:${PORTNUMBER_BASE}82:82	\
		--publish 127.0.0.1:${PORTNUMBER_BASE}83:83	\
		--publish 127.0.0.1:${PORTNUMBER_BASE}84:84	\
		--publish 127.0.0.1:${PORTNUMBER_BASE}85:85	\
		--publish 127.0.0.1:${PORTNUMBER_BASE}86:86	\
		--publish 127.0.0.1:${PORTNUMBER_BASE}87:87	\
		--publish 127.0.0.1:${PORTNUMBER_BASE}88:88	\
		--publish 127.0.0.1:${PORTNUMBER_BASE}89:89	\
		--add-host=dolibarr:127.0.0.1	\
		--add-host=mariadb:127.0.0.1	\
		--add-host=phpmyadmin:127.0.0.1	\
		--name "${PODNAME}"
}

for VERSION in ${ACTIVE_VERSIONS}; do
	create_pod ${VERSION}
done


