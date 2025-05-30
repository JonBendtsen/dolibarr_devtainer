#!/bin/bash

# set -e # deliberately
set -o pipefail
source local.config || ( echo "ERROR, create a local.config file from default.config" ; exit 1 )

RNG="openssl rand -hex 16"

function create_secrets {
    TOP_SECRET=$(${RNG}) podman secret create --env=true $1 TOP_SECRET
}

VOL_ERR="you can not create a new podman secret and use it for an existing mariadb podman volume because the passwords will then mismatch, you will have to DELETE this mariadb volume and thus all the data in it. BE CAREFUL!"
for VERSION in ${ACTIVE_VERSIONS}; do
    VOLUME_NAME="mariadb_${VERSION}"
    podman volume exists "${VOLUME_NAME}"
    CHECK_VOLUME=$?
    if [[ 0 -eq ${CHECK_VOLUME} ]]; then
        echo "Warning! '${VOLUME_NAME}' - ${VOL_ERR}"
        continue
    fi

    SECRET_ROOT_pass="${SECRET_ROOT_BASE}_${VERSION}"
    podman secret exists "${SECRET_ROOT_pass}" \
        || create_secrets ${SECRET_ROOT_pass}

    SECRET_DOLI_pass="${SECRET_DOLI_BASE}_${VERSION}"
    podman secret exists "${SECRET_DOLI_pass}" \
        || create_secrets ${SECRET_DOLI_pass}
done

podman secret ls
