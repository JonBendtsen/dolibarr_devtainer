#!/bin/bash
SRC_CFG="$1"

set -e
set -o pipefail
source ${SRC_CFG}

function create_dolibarr_with_our_htdocs {
	VERSION=$1
	PODNAME="${POD_BASENAME}_${VERSION}"
	MARIADB_NAME="${MARIADB_BASENAME}_${VERSION}"
	CONTAINER_NAME="${DOLIBARR_BASENAME}_${VERSION}"
	SECRET_DOLI_pass="${SECRET_DOLI_BASE}_${VERSION}"
	IMAGE_VERSION=$( echo "${VERSION}" | cut -d"." -f1 )
	if [[ "develop" == "${VERSION}" ]]; then
		PORTNUMBER_BASE=80
	else
		PORTNUMBER_BASE=$( echo "${VERSION}" | tr -c -d "[:digit:]" )
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
		--volume dolibarr_api_${VERSION}:/var/www/documents/api:rw \
		--volume dolibarr_api_temp_${VERSION}:/var/www/documents/api/temp:rw \
		${IMAGE_REGISTRY}/dolibarr/dolibarr:${IMAGE_VERSION}
}

function create_demo_dolibarr {
	VERSION=$1
	PODNAME="${POD_BASENAME}_${VERSION}"
	MARIADB_NAME="${MARIADB_BASENAME}_${VERSION}"
	CONTAINER_NAME="${DOLIBARR_BASENAME}_${VERSION}"
	SECRET_DOLI_pass="${SECRET_DOLI_BASE}_${VERSION}"
	SECRET_ADMi_pass="${SECRET_ADMi_BASE}_${VERSION}"
	SECRET_CRON_KEY="${SECRET_CRON_KEY_BASE}_${VERSION}"
	IMAGE_VERSION=$( echo "${VERSION}" | cut -d"." -f1 )
	if [[ "develop" == "${VERSION}" ]]; then
		PORTNUMBER_BASE=80
	else
		TMP_PORTNUMBER_BASE=$( echo "${VERSION}" | tr -c -d "[:digit:]" )
		PORTNUMBER_BASE=$(( 2* ${TMP_PORTNUMBER_BASE} ))
	fi

	if [[ -s "dolibarr_modules_${VERSION}.csv" ]]; then
		source "dolibarr_modules_${VERSION}.csv"
	else
		DOLI_MODULES=""
	fi

	podman container exists ${CONTAINER_NAME} || podman create \
		--tz=local \
		--pod ${PODNAME} \
		--name ${CONTAINER_NAME} \
		--requires=${MARIADB_NAME} \
		--secret "${SECRET_DOLI_pass}",type=env,target=DOLI_DB_PASSWORD \
		--secret "${SECRET_ADMi_pass}",type=env,target=DOLI_ADMIN_PASSWORD \
		--secret "${SECRET_CRON_KEY}",type=env,target=DOLI_CRON_KEY \
		--env DOLI_PROD=1 \
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
		--env DOLI_COMPANY_NAME="DemoCapo" \
		--env DOLI_COMPANY_COUNTRYCODE="DK" \
		--env DOLI_ENABLE_MODULES="${DOLI_MODULES}" \
		--volume demobarr_conf_${VERSION}:/var/www/html/conf:rw \
		--volume demobarr_custom_${VERSION}:/var/www/html/custom:rw \
		--volume demobarr_theme_${VERSION}:/var/www/html/theme:rw \
		--volume demobarr_docs_${VERSION}:/var/www/documents:rw \
		--volume demobarr_api_${VERSION}:/var/www/documents/api:rw \
		--volume demobarr_api_temp_${VERSION}:/var/www/documents/api/temp:rw \
		${IMAGE_REGISTRY}/dolibarr/dolibarr:${IMAGE_VERSION}
}

if [[ -z ${DEMO_VERSIONS+x} ]]; then
	for VERSION in ${ACTIVE_VERSIONS}; do
		create_dolibarr_with_our_htdocs ${VERSION}
	done
else
	for VERSION in ${DEMO_VERSIONS}; do
		create_demo_dolibarr ${VERSION}
	done
fi
