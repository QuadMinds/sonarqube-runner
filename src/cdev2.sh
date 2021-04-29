#!/usr/bin/env bash
source ${PWD}/src/functions.sh

CONFIG_PATH=${PWD}/config/cdev2

before_scan() {
    # openjdk:8-alpine
    # thyrlian/android-sdk

    mkdir -p ${PWD}/.ts/.gradle ${PWD}/.ts/android-sdk-linux /${PWD}/.ts/.android
    PROJECT_DIR=${TMP_DIR}/control-entregas-v2

    echo "Lint Kotlin"
    docker run \
        --rm \
        --interactive \
        --tty \
        --volume "${PROJECT_DIR}:/app" \
        --volume "${PWD}/.ts/android-sdk-linux:/app/android-sdk-linux" \
        --volume "${PWD}/.ts/.gradle:/app/.gradle" \
        --volume "${PWD}/config/cdev2:/app/scripts" \
        --volume "${PWD}/.ts/.android:/.android" \
        --user ${LUID}:${LGID} \
        --cap-add=FOWNER \
        --entrypoint /bin/sh \
        --workdir /app \
        openjdk:8-alpine -c "/app/scripts/run.sh;"    
}

# Run script
source ${PWD}/src/run.sh ${CONFIG_PATH}