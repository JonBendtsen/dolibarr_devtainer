#!/bin/bash
SRC_CFG="$1"

set -e
set -o pipefail
source ${SRC_CFG}

function create_mariadb {
	VERSION=$1
	PODNAME="${POD_BASENAME}_${VERSION}"
	CONTAINER_NAME="${MARIADB_BASENAME}_${VERSION}"
	SECRET_ROOT_pass="${SECRET_ROOT_BASE}_${VERSION}"
	SECRET_DOLI_pass="${SECRET_DOLI_BASE}_${VERSION}"

	podman container exists ${CONTAINER_NAME} || podman create \
		--tz=local \
		--pod ${PODNAME} \
		--name ${CONTAINER_NAME} \
		--env MARIADB_DATABASE="dolidb" \
		--env MARIADB_USER="doliuser" \
		--env MARIADB_AUTO_UPGRADE="true" \
		--secret "${SECRET_ROOT_pass}",type=env,target=MARIADB_ROOT_PASSWORD \
		--secret "${SECRET_DOLI_pass}",type=env,target=MARIADB_PASSWORD \
		--volume mariadb_${VERSION}:/var/lib/mysql:rw \
		--volume "${HOME}/${DB_RESTORE_FROM_PATH}/${DB_RESTORE_FROM_FILE}:/docker-entrypoint-initdb.d/${DB_RESTORE_FROM_FILE}:rw" \
		${IMAGE_REGISTRY}/mariadb:latest \
		--bind-address=127.0.0.1 \
		--port=3306
}

function create_demodb {
	VERSION=$1
	PODNAME="${POD_BASENAME}_${VERSION}"
	CONTAINER_NAME="${MARIADB_BASENAME}_${VERSION}"
	SECRET_ROOT_pass="${SECRET_ROOT_BASE}_${VERSION}"
	SECRET_DOLI_pass="${SECRET_DOLI_BASE}_${VERSION}"

	podman container exists ${CONTAINER_NAME} || podman create \
		--tz=local \
		--pod ${PODNAME} \
		--name ${CONTAINER_NAME} \
		--env MARIADB_DATABASE="dolidb" \
		--env MARIADB_USER="doliuser" \
		--env MARIADB_AUTO_UPGRADE="true" \
		--secret "${SECRET_ROOT_pass}",type=env,target=MARIADB_ROOT_PASSWORD \
		--secret "${SECRET_DOLI_pass}",type=env,target=MARIADB_PASSWORD \
		--volume demodb_${VERSION}:/var/lib/mysql:rw \
		${IMAGE_REGISTRY}/mariadb:latest \
		--bind-address=127.0.0.1 \
		--port=3306
}

if [[ -z ${DEMO_VERSIONS+x} ]]; then
	for VERSION in ${ACTIVE_VERSIONS}; do
		create_mariadb ${VERSION}
	done
else
	for VERSION in ${DEMO_VERSIONS}; do
		create_demodb ${VERSION}
	done
fi