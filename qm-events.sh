#!/usr/bin/env bash
source ${PWD}/src/functions.sh

CONFIG_PATH=${PWD}/config/qm-events

# Variables 
# CONFIG_PATH
# TMP_DIR


before_scan() {
    echo -e "\e[0m🤖 Restore packages"
    NPM_CACHE=$(mktemp -d)
    PROJECT_DIR=${TMP_DIR}/quadminds-events
    mkdir -p "${NPM_CACHE}/_locks" "${NPM_CACHE}/_config" "${NPM_CACHE}/_cache" 
	docker run \
        --rm \
        --interactive \
        --tty \
        --volume "${PROJECT_DIR}:/app" \
        --volume "${HOME}/.npmrc:/app/.npmrc" \
        --volume "${NPM_CACHE}:/.npm" \
        --volume "${NPM_CACHE}/_config:/.config" \
        --volume "${NPM_CACHE}/_cache:/.cache" \
        --workdir /app \
        --user ${LUID}:${LGID} \
        --cap-add=FOWNER \
        --entrypoint /bin/sh \
        node:12.13-alpine \
		-c "node --version | xargs echo 🌀 node: && npm --version | xargs echo 🚚 npm: && pwd | xargs echo 🔻 dir: && echo && npm install --loglevel=error"
    rm -rf ${NPM_CACHE}
    pushd ${PROJECT_DIR}
    touch ${PROJECT_DIR}/.env
    # make cov
    echo
    docker build \
        -t qm-events-cov \
        -f ${PROJECT_DIR}/deployment/Cov.Dockerfile .
    echo
    docker build \
        -t qm-events-lint \
        -f ${PROJECT_DIR}/deployment/Lint.Dockerfile .
    echo
    docker run \
        --rm \
        --interactive \
        --tty \
        --volume "${PROJECT_DIR}:/app" \
        --user ${LUID}:${LGID} \
        --cap-add=FOWNER \
        qm-events-cov
    echo
    docker run \
        --rm \
        --interactive \
        --tty \
        --volume "${PROJECT_DIR}:/app" \
        --user ${LUID}:${LGID} \
        --cap-add=FOWNER \
        --entrypoint /bin/sh \
        qm-events-lint -c "node --version | xargs echo 🌀 node: && npm --version | xargs echo 🚚 npm: && pwd | xargs echo 🔻 dir: && echo && npm run lint:report --loglevel=error"
    popd
}

# Run script
source ${PWD}/src/run.sh ${CONFIG_PATH}