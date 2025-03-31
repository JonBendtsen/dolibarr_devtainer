#!/bin/bash

set -e
set -o pipefail
source local.config || ( echo "ERROR, create a local.config file from default.config" ; exit 1 )

function create_phpmyadmin {
	IMAGE_VERSION=$1
	if [[ "develop" == "${IMAGE_VERSION}" ]]; then
		PORTNUMBER_BASE=100
	else
		PORTNUMBER_BASE=$( echo "${IMAGE_VERSION}" | tr -c -d "[:digit:]" )
	fi
	PODNAME="${POD_BASENAME}_${IMAGE_VERSION}"
	CONTAINER_NAME="${PHPMYADMIN_BASENAME}_${IMAGE_VERSION}"
	SECRET_ROOT_pass="${SECRET_ROOT_BASE}_${VERSION}"

	podman container exists ${CONTAINER_NAME} || podman create \
		--tz=local \
		--pod ${PODNAME} \
		--name ${CONTAINER_NAME} \
		--env PMA_HOST="mariadb" \
		--env PMA_PORT=3306  \
		--env PMA_PMADB="phpmyadmin" \
		--env PMA_QUERYHISTORYDB=true \
		--env APACHE_PORT="${PORTNUMBER_BASE}36"	\
		--env PMA_ABSOLUTE_URI="http://localhost:${PORTNUMBER_BASE}36/"		\
		--secret "${SECRET_ROOT_pass},type=env,target=MYSQL_ROOT_PASSWORD" 	\
		${IMAGE_REGISTRY}/library/phpmyadmin:latest
}

for VERSION in ${ACTIVE_VERSIONS}; do
	create_phpmyadmin ${VERSION}
done
