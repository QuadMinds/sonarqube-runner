#!/usr/bin/env bash

RED='\e[31m'
_ERR_HDR_FMT="%.23s %s[%s]: "
_ERR_MSG_FMT="${_ERR_HDR_FMT}%s\n"

error_msg() {
  echo
  echo
  echo -e "${RED}🔥 ${@} ${BASH_SOURCE[1]##*/}:${FUNCNAME[1]}[${BASH_LINENO[0]}] ${BASH_LINENO} ${PWD}"
  printf "$_ERR_MSG_FMT" $(date +%F.%T.%N)🔥 ${BASH_SOURCE[1]##*/} ${BASH_LINENO[0]} "${@}"
  echo
  echo
}

git_clone() {
    
    pushd $1

    # https://linuxhint.com/bash_split_examples/
    # Set space as the delimiter
    IFS=';'

    # Read the split words into an array based on space delimiter
    read -a arr <<< "$3"
    for val in "${arr[@]}";
    do
        REPO=${val/\'/""}
        echo -e "\e[1;32m📥 git clone ${REPO}\e[0m"
        echo
        git clone \
            --depth=1 \
            --single-branch \
            --branch $2 \
            --recursive \
            git@github.com:QuadMinds/${REPO}.git ${REPO} && echo -e "\e[1;32m✅ git clone ${REPO}\e[0m" && echo -e "\e[0m" || { error_msg "ERROR GIT CLONE ${REPO}"; exit 1; }
        echo
    done
    popd    
}

git_checkout() {
    # https://linuxhint.com/bash_split_examples/
    # Set space as the delimiter
    IFS=';'

    # Read the split words into an array based on space delimiter
    read -a arr <<< "$3"
    for val in "${arr[@]}";
    do
        REPO=${val/\'/""}
        echo -e "\e[1;32m🚪 git checkout ${REPO}\e[0m"
        echo
        pushd "$1/${REPO}"
        git checkout $2 && echo -e "\e[1;32m✅ git checkout ${REPO}\e[0m" && echo -e "\e[0m" || ( error_msg "ERROR GIT CHECKOUT ${REPO}"; exit 1; )
        echo -e "\e[0m"
        
        git submodule update \
            --init \
            --recursive && echo -e "\e[1;32m✅ git submodule init ${REPO}\e[0m" && echo -e "\e[0m" || ( error_msg "ERROR GIT SUBMODULE ${REPO}"; exit 1; )
        popd
    done
    
    echo -e "\e[0m"
}

before_scan() { 
    echo -e "\e[1;32m📜 Before run scan"
}

save_function() {
    local ORIG_FUNC=$(declare -f $1)
    local NEWNAME_FUNC="$2${ORIG_FUNC#$1}"
    eval "$NEWNAME_FUNC"
}
