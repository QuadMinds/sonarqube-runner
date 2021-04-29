#!/usr/bin/env bash

CONFIG_PATH=$1

# Load variables 
echo -e "🔄 Load variables: ${CONFIG_PATH}/.env"
export $(cat ${CONFIG_PATH}/.env | sed 's/#.*//g' | xargs)

echo -e "🚩 Quadminds - ${TITLE} - Sonarqube"
echo

TMP_DIR=$(mktemp -d)
echo -e "📂 Temp directory ${TMP_DIR}\e[0m"
echo

# Variables
LUID=$(id -u)
LGID=$(id -g)

if [ -z ${BRANCH} ]; then
    BRANCH=master
fi

echo -e "📦 git version: $(git --version) ✔️\e[0m" || ( error_msg ERROR FALTA GIT; exit 1; )
echo

# Clone sources
git_clone ${TMP_DIR} ${BRANCH} ${PRODUCT}
echo

git_checkout ${TMP_DIR} ${BRANCH} ${PRODUCT}
echo

echo -e "\e[1;32m💾 Copy config\e[0m"
echo
cp --force ${CONFIG_PATH}/sonar-scanner.properties ${TMP_DIR}
cat <<EOT > .env
U_ID=${LUID} 
G_ID=${LGID} 
PROJECT_SOURCE=${TMP_DIR}
EOT

chmod 777 -R ${TMP_DIR}

# Before scan
before_scan
echo

echo -e "\e[1;32m🔍 Run sonarqube scanner in ${TMP_DIR}\e[0m"
U_ID=${LUID} G_ID=${LGID} PROJECT_SOURCE=${TMP_DIR} docker-compose up --build scanner
echo

echo -e "🚀 Finish"
rm -rf ${TMP_DIR}

echo -e "📂 Temp directory ${TMP_DIR}\e[0m"
echo


