#!/usr/bin/env bash

# Color variables. Used when displaying messages in stdout.
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;36m'; NC='\033[0m'

# Message types. Used when displaying messages in stdout.
OK=$(echo -e "[ ${GREEN} OK ${NC} ]"); ER=$(echo -e "[ ${RED} ER ${NC} ]"); INFO=$(echo -e "[ ${BLUE}INFO${NC} ]")

# BASEDIR contains pzlsm script directory. Note: Not all systems have readlink.
# Use this if your system does not have readlink: BASEDIR=$(dirname "$BASH_SOURCE")
# But this doesn't work if you've called the script via a symbolic link in
# a different directory.
BASEDIR=$(dirname "$(readlink -f "$BASH_SOURCE")")

# Import config file if exists.
if [ -n "$1" ]; then
    SERVER_TYPE="$1"

    DIR_INCLUDE="${BASEDIR}/include"
    DIR_PZLSM_CONFIG="${DIR_INCLUDE}/config/pzlsm"

    FILE_DEPLOY_CONFIG="${DIR_INCLUDE}/config/deploy/${SERVER_TYPE}.sh"

    test -f ${FILE_DEPLOY_CONFIG} && . ${FILE_DEPLOY_CONFIG}
fi

# Or get variables from env if exists.
SERVER_IP=${SERVER_IP}
SERVER_USER=${SERVER_USER}
SERVER_PASSWORD=${SERVER_PASSWORD}

if [ -z "${SERVER_IP}" ]; then
    >&2 echo "$ER SERVER_IP is not set"
    exit
fi

if [ -z "${SERVER_USER}" ]; then
    >&2 echo "$ER SERVER_USER is not set"
    exit
fi

if [ -z "${SERVER_PASSWORD}" ]; then
    >&2 echo "$ER SERVER_PASSWORD is not set"
    echo $SERVER_IP
    exit
fi

SERVER_PZ_DIR="/home/${SERVER_USER}/pz"

exp ${SERVER_PASSWORD} ssh -o 'IdentitiesOnly=yes' "${SERVER_USER}@${SERVER_IP}" "mkdir -p ${SERVER_PZ_DIR}/include/config/pzlsm"
exp ${SERVER_PASSWORD} scp -o 'IdentitiesOnly=yes' "${DIR_PZLSM_CONFIG}/default.sh" "${SERVER_USER}@${SERVER_IP}":"${SERVER_PZ_DIR}/include/config/pzlsm"
exp ${SERVER_PASSWORD} scp -o 'IdentitiesOnly=yes' server.sh "${SERVER_USER}@${SERVER_IP}":"${SERVER_PZ_DIR}/"
