#!/bin/bash

set -e
set -o pipefail
source local.config || ( echo "ERROR, create a local.config file from default.config" ; exit 1 )

function create_dolibarr {
	VERSION=$1
	PODNAME="${POD_BASENAME}_${VERSION}"
	MARIADB_NAME="${MARIADB_BASENAME}_${VERSION}"
	CONTAINER_NAME="${DOLIBARR_BASENAME}_${VERSION}"
	SECRET_DOLI_pass="${SECRET_DOLI_BASE}_${VERSION}"
	IMAGE_VERSION=$( echo "${VERSION}" | cut -d"." -f1 )
	if [[ "develop" == "${IMAGE_VERSION}" ]]; then
		PORTNUMBER_BASE=80
	else
		PORTNUMBER_BASE=$( echo "${IMAGE_VERSION}" | tr -c -d "[:digit:]" )
	fi
	if [[ "develop" == "${VERSION}" ]]; then
		HTDOCS="${LOCAL_DOLIBARR_REPO}/htdocs"
	else
		HTDOCS="${LOCAL_WORKTREE_BASE}/${VERSION}/htdocs"
	fi
	if [[ -d "${HTDOCS}" ]]; then
		true
	else
		echo "ERROR, HTDOCS=${HTDOCS} is not a directory or does not exist?"
		exit 1
	fi
	podman container exists ${CONTAINER_NAME} || podman create \
		--tz=local \
		--pod ${PODNAME} \
		--name ${CONTAINER_NAME} \
		--requires=${MARIADB_NAME} \
		--secret "${SECRET_DOLI_pass}",type=env,target=DOLI_DB_PASSWORD \
		--env DOLI_PROD=0 \
		--env DOLI_DB_TYPE="mysqli" \
		--env DOLI_DB_HOST="mariadb" \
		--env DOLI_DB_HOST_PORT=3306 \
		--env DOLI_DB_NAME="dolidb" \
		--env DOLI_DB_USER="doliuser" \
		--env DOLI_ADMIN_LOGIN="${DOLI_ADMIN_LOGIN}" \
		--env DOLI_URL_ROOT="http://localhost:${PORTNUMBER_BASE}80/" \
		--env DOLI_HTTPS="0" \
		--env DOLI_NO_CSRF_CHECK="0" \
		--env PHP_INI_DATE_TIMEZONE="${PHP_INI_DATE_TIMEZONE}" \
		--env PHP_INI_MEMORY_LIMIT="256M" \
		--env PHP_INI_UPLOAD_MAX_FILESIZE="2M" \
		--env PHP_INI_POST_MAX_SIZE="8M" \
		--env PHP_INI_ALLOW_URL_FOPEN=0 \
		--env our_HTDOCS=${HTDOCS} \
		--volume ${HTDOCS}:/var/www/html:rw \
		--volume dolibarr_conf_${VERSION}:/var/www/html/conf:rw \
		--volume dolibarr_custom_${VERSION}:/var/www/html/custom:rw \
		--volume dolibarr_theme_${VERSION}:/var/www/html/theme:rw \
		--volume dolibarr_docs_${VERSION}:/var/www/documents:rw \
		${IMAGE_REGISTRY}/dolibarr/dolibarr:${IMAGE_VERSION}
}

for VERSION in ${ACTIVE_VERSIONS}; do
	create_dolibarr ${VERSION}
done
