#!/usr/bin/env bash
source ${PWD}/src/functions.sh

CONFIG_PATH=${PWD}/config/fleet

before_scan() {
    # https://linuxhint.com/bash_split_examples/
    # Set space as the delimiter
    IFS=';'

    # Read the split words into an array based on space delimiter
    read -a arr <<< "${PRODUCT}"
    for val in "${arr[@]}";
    do
        REPO=${val/\'/""}
        # echo -e "\e[1;32m🔍 go vet ${REPO}\e[0m"
        # echo
        # docker run --rm -v "${TMP_DIR}/${REPO}":/src -w /src golang:1.16 go vet ./... -json || { error_msg "ERROR go vet ${REPO}"; exit 1; }
        # docker run --rm -v "${TMP_DIR}/${REPO}":/src -w /src golang:1.16 golint -set_exit_status ./... || { error_msg "ERROR go vet ${REPO}"; exit 1; }        
        # echo
    done
}

# Run script
source ${PWD}/src/run.sh ${CONFIG_PATH}
