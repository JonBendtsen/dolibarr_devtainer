#!/bin/bash
SRC_CFG="$1"

set -e
set -o pipefail
source ${SRC_CFG}

function create_pod {
	VERSION=$1
	if [[ "develop" == "${VERSION}" ]]; then
		PORTNUMBER_BASE=80
	else
		PORTNUMBER_BASE=$( echo "${VERSION}" | tr -c -d "[:digit:]" )
	fi
	PODNAME="${POD_BASENAME}_${VERSION}"
	podman pod exists "${PODNAME}" || podman pod create \
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}36:${PORTNUMBER_BASE}36	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}80:80	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}81:81	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}82:82	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}83:83	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}84:84	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}85:85	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}86:86	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}87:87	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}88:88	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}89:89	\
		--add-host=dolibarr:127.0.0.1	\
		--add-host=mariadb:127.0.0.1	\
		--add-host=phpmyadmin:127.0.0.1	\
		--name "${PODNAME}"
}

function create_demo_pod {
	VERSION=$1
	if [[ "develop" == "${VERSION}" ]]; then
		PORTNUMBER_BASE=60
	else
		TMP_PORTNUMBER_BASE=$( echo "${VERSION}" | tr -c -d "[:digit:]" )
		PORTNUMBER_BASE=$(( 2* ${TMP_PORTNUMBER_BASE} ))
	fi
	PODNAME="${POD_BASENAME}_${VERSION}"
	podman pod exists "${PODNAME}" || podman pod create \
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}36:${PORTNUMBER_BASE}36	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}80:80	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}81:81	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}82:82	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}83:83	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}84:84	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}85:85	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}86:86	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}87:87	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}88:88	\
		--publish ${PUBLISH_IPv4}:${PORTNUMBER_BASE}89:89	\
		--add-host=dolibarr:127.0.0.1	\
		--add-host=mariadb:127.0.0.1	\
		--add-host=phpmyadmin:127.0.0.1	\
		--name "${PODNAME}"
}

if [[ -z ${DEMO_VERSIONS+x} ]]; then
	for VERSION in ${ACTIVE_VERSIONS}; do
		create_pod ${VERSION}
	done
else
	for VERSION in ${DEMO_VERSIONS}; do
		create_demo_pod ${VERSION}
	done
fi

