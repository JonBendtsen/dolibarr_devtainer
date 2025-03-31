#!/bin/bash

# set -e # deliberate
set -o pipefail
source local.config || ( echo "ERROR, create a local.config file from default.config" ; exit 1 )

mkdir -p "${LOCAL_REPO_BASE}"
mkdir -p "${LOCAL_WORKTREE_BASE}"

if [[ -d "${LOCAL_DOLIBARR_REPO}" ]]; then
    CURRENT_DIR="${PWD}"
    cd "${LOCAL_DOLIBARR_REPO}" \
        && git switch develop   \
        && git pull \
        && cd "${CURRENT_DIR}"
else
    git clone "${YOUR_GITHUB_FORK}" "${LOCAL_DOLIBARR_REPO}"
fi

TMPBRANCH=tmp_$(openssl rand -hex 8)
IFS_1727="${IFS}"
IFS=" "
for VERSION in ${ACTIVE_VERSIONS}; do
    if [[ "develop" == "${VERSION}" ]]; then
        continue
    fi
    echo "%%%%%%%%%%%%%%%%  Version = ${VERSION}  %%%%%%%%%%%%%%%%"
    cd "${LOCAL_DOLIBARR_REPO}"
    git branch -r | grep "origin/${VERSION}"
    GREP_CODE=$?
    if [[ 0 -ne ${GREP_CODE} ]]; then
        git branch -r
        echo "ERROR, there is no origin/branch with version ${VERSION}"
        exit 1
    fi
    git branch --track "${VERSION}" "origin/${VERSION}"
    git fetch --all && git pull --all
    git worktree add -b ${TMPBRANCH} "${LOCAL_WORKTREE_BASE}/${VERSION}"
    cd "${LOCAL_WORKTREE_BASE}/${VERSION}" && git status -sb
    git switch ${VERSION} && git pull
    git branch -D ${TMPBRANCH}
done

IFS="${IFS_1727}"
