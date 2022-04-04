#!/bin/bash

# Project Zomboid Linux Server Manager.
#
# Copyright (c) 2021 Pavel Korotkiy (outdead).
# Use of this source code is governed by the MIT license.
#
# DO NOT EDIT THIS FILE!
#
# To change config go to include/config-default.sh file.
# You can copy the config-default.sh file to the config-local.sh
# file and make changes to it as you wish.
# The config-local.sh file will never be updated automatically.

# VERSION of Project Zomboid Linux Server Manager.
# Follows semantic versioning, SEE: http://semver.org/.
VERSION="0.19.22"

BASEDIR=$(dirname "$(readlink -f "$BASH_SOURCE")")

# Color variables. Used when displaying messages in stdout.
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;36m'; NC='\033[0m'

# Message types. Used when displaying messages in stdout.
OK=$(echo -e "[ ${GREEN} OK ${NC} ]"); ER=$(echo -e "[ ${RED} ER ${NC} ]"); INFO=$(echo -e "[ ${BLUE}INFO${NC} ]")

# MEMORY_AVAILABLE is the amount of memory available on the server in MB.
MEMORY_AVAILABLE=$(free | awk 'NR==2 { printf("%.0f", $2/1024); }')

# MEMORY_USED is the amount of memory used on the server in MM.
MEMORY_USED=$(free | awk 'NR==2 { printf("%.0f", $3/1024); }')

# CPU_CORE_COUNT is the number of processors cores on the server.
CPU_CORE_COUNT=$(nproc)

# Project Zomboid App ID and Dedicated Server App ID in Steam.
APP_ID=108600
APP_DEDICATED_ID=380870

# SCREEN_ZOMBOID contains the name of the screen to launch Project Zomboid.
SCREEN_ZOMBOID="zomboid"

# NOW is the current date and time in default format Y%m%d_%H%M%S.
# You can change format in config file.
NOW=$(date "+%Y%m%d_%H%M%S")

# TIMESTAMP is current timestamp.
TIMESTAMP=$(date "+%s")

# Linux Server Manager directories definitions.
DIR_BACKUPS="${BASEDIR}/backups"
DIR_PUBLIC="${BASEDIR}/public"
DIR_UTILS="${BASEDIR}/utils"
DIR_INCLUDE="${BASEDIR}/include"
DIR_PZLSM_CONFIG="${DIR_INCLUDE}/config/pzlsm"

# Linux Server Manager files definitions.
FILE_PZLSM_LOG="${BASEDIR}/server.log"
FILE_PZLSM_CONFIG_DEFAULT="${DIR_PZLSM_CONFIG}/default.sh"
FILE_PZLSM_CONFIG_LOCAL="${DIR_PZLSM_CONFIG}/local.sh"
FILE_PZLSM_CONFIG_ENV="${BASEDIR}/.env"
FILE_PZLSM_UPDATE="${BASEDIR}/server.update"

# Import config files if exists.
# shellcheck source=include/config/default.sh
test -f "${FILE_PZLSM_CONFIG_DEFAULT}" && . "${FILE_PZLSM_CONFIG_DEFAULT}"
# shellcheck source=include/config/local.sh
test -f "${FILE_PZLSM_CONFIG_LOCAL}" && . "${FILE_PZLSM_CONFIG_LOCAL}"
# shellcheck source=.env
test -f "${FILE_PZLSM_CONFIG_ENV}" && . "${FILE_PZLSM_CONFIG_ENV}"

## Check config variables and set default values if not defined.
[ -z "${CLEAR_MAP_DAY}" ] && CLEAR_MAP_DAY=21
[ -z "${CLEAR_LOGS_DAY}" ] && CLEAR_LOGS_DAY=1000
[ -z "${CLEAR_STACK_TRACE_DAY}" ] && CLEAR_STACK_TRACE_DAY=1000
[ -z "${CLEAR_BACKUPS_DAY}" ] && CLEAR_BACKUPS_DAY=1000
[ -z "${CLEAR_TIME_MACHINE_DAY}" ] && CLEAR_TIME_MACHINE_DAY=5
[ -z "${UTIL_RANGE_VERSION}" ] && UTIL_RANGE_VERSION="1.0.0"
[ -z "${UTIL_RCON_VERSION}" ] && UTIL_RCON_VERSION="0.4.0"
[ -z "${SERVER_MEMORY_LIMIT}" ] && SERVER_MEMORY_LIMIT=2048
[ -z "${SERVER_NAME}" ] && SERVER_NAME="servertest"
[ -z "${SERVER_LANG}" ] && SERVER_LANG="en"
[ -z "${SERVER_DIR}" ] && SERVER_DIR="${HOME}/pz/server"
[ -z "${ZOMBOID_DIR}" ] && ZOMBOID_DIR="${SERVER_DIR}/Zomboid"
[ -z "${FIRST_RUN_ADMIN_PASSWORD}" ] && FIRST_RUN_ADMIN_PASSWORD="changeme"
[ -z "${BACKUP_ON_STOP}" ] && BACKUP_ON_STOP="false"

[ -z "${STEAMCMD_USERNAME}" ] && STEAMCMD_USERNAME="anonymous"
[ -z "${STEAMCMD_VALIDATE}" ] && STEAMCMD_VALIDATE=""
[ -z "${STEAMCMD_BETA}" ] && STEAMCMD_BETA=""

## Utils

# Numeric range regular expression builder written in bash.
# https://github.com/outdead/regex-range-builder.
UTIL_RANGE_LINK="https://github.com/outdead/regex-range-builder/archive/v${UTIL_RANGE_VERSION}.tar.gz"
UTIL_RANGE_DIR="${DIR_UTILS}/regex-range-builder-${UTIL_RANGE_VERSION}"
UTIL_RANGE_FILE="${UTIL_RANGE_DIR}/range.sh"

# Rcon client for executing queries on game server.
# https://github.com/gorcon/rcon-cli.
UTIL_RCON_LINK="https://github.com/gorcon/rcon-cli/releases/download/v${UTIL_RCON_VERSION}/rcon-${UTIL_RCON_VERSION}-amd64_linux.tar.gz"
UTIL_RCON_DIR="${DIR_UTILS}/rcon-${UTIL_RCON_VERSION}-amd64_linux"
UTIL_RCON_FILE="${UTIL_RCON_DIR}/rcon"

## Directories in Zomboid folder.

ZOMBOID_DIR_SAVES="${ZOMBOID_DIR}/Saves"
ZOMBOID_DIR_LOGS="${ZOMBOID_DIR}/Logs"
ZOMBOID_DIR_SERVER="${ZOMBOID_DIR}/Server"
ZOMBOID_DIR_DB="${ZOMBOID_DIR}/db"
ZOMBOID_DIR_MAP="${ZOMBOID_DIR_SAVES}/Multiplayer/${SERVER_NAME}"

ZOMBOID_FILE_CONFIG_INI="${ZOMBOID_DIR_SERVER}/${SERVER_NAME}.ini"
ZOMBOID_FILE_CONFIG_SANDBOX="${ZOMBOID_DIR_SERVER}/${SERVER_NAME}_SandboxVars.lua"
ZOMBOID_FILE_CONFIG_SPAWNPOINTS="${ZOMBOID_DIR_SERVER}/${SERVER_NAME}_spawnpoints.lua"
ZOMBOID_FILE_CONFIG_SPAWNREGIONS="${ZOMBOID_DIR_SERVER}/${SERVER_NAME}_spawnregions.lua"
ZOMBOID_FILE_DB="${ZOMBOID_DIR_DB}/${SERVER_NAME}.db"

ZOMBOID_MANIFEST="${SERVER_DIR}/steamapps/appmanifest_${APP_DEDICATED_ID}.acf"
ZOMBOID_MODS_MANIFEST="${SERVER_DIR}/steamapps/workshop/appworkshop_${APP_ID}.acf"

# echoerr prints error message to stderr and FILE_PZLSM_LOG file.
function echoerr() {
  echo "${ER} $1"
  echo "[$(date "+%Y-%m-%d %H:%M:%S")] $0 - $1" >> "${FILE_PZLSM_LOG}"
}

# print_variables prints pzlsm variables.
function print_variables() {
  echo "${INFO} MEMORY_AVAILABLE:            ${MEMORY_AVAILABLE}"
  echo "${INFO} MEMORY_USED:                 ${MEMORY_USED}"
  echo "${INFO} CPU_CORE_COUNT:              ${CPU_CORE_COUNT}"
  echo "${INFO} APP_ID:                      ${APP_ID}"
  echo "${INFO} APP_DEDICATED_ID:            ${APP_DEDICATED_ID}"
  echo "${INFO} SCREEN_ZOMBOID:              ${SCREEN_ZOMBOID}"
  echo "${INFO} NOW:                         ${NOW}"
  echo "${INFO} TIMESTAMP:                   ${TIMESTAMP}"
  echo "${INFO} BASEDIR:                     ${BASEDIR}"

  echo "${INFO} DIR_BACKUPS:                 ${DIR_BACKUPS}"
  echo "${INFO} DIR_UTILS:                   ${DIR_UTILS}"
  echo "${INFO} DIR_INCLUDE:                 ${DIR_INCLUDE}"
  echo "${INFO} DIR_PZLSM_CONFIG:            ${DIR_PZLSM_CONFIG}"

  echo "${INFO} FILE_PZLSM_LOG:              ${FILE_PZLSM_LOG}"
  echo "${INFO} FILE_PZLSM_CONFIG_DEFAULT:   ${FILE_PZLSM_CONFIG_DEFAULT}"
  echo "${INFO} FILE_PZLSM_CONFIG_LOCAL:     ${FILE_PZLSM_CONFIG_LOCAL}"
  echo "${INFO} FILE_PZLSM_UPDATE:           ${FILE_PZLSM_UPDATE}"

  echo "${INFO} UTIL_RANGE_FILE:             ${UTIL_RANGE_FILE}"
  echo "${INFO} UTIL_RCON_FILE:              ${UTIL_RCON_FILE}"

  echo "${INFO} ZOMBOID_DIR_SAVES:           ${ZOMBOID_DIR_SAVES}"
  echo "${INFO} ZOMBOID_DIR_LOGS:            ${ZOMBOID_DIR_LOGS}"
  echo "${INFO} ZOMBOID_DIR_SERVER:          ${ZOMBOID_DIR_SERVER}"
  echo "${INFO} ZOMBOID_DIR_DB:              ${ZOMBOID_DIR_DB}"
  echo "${INFO} ZOMBOID_DIR_MAP:             ${ZOMBOID_DIR_MAP}"
  echo "${INFO} ZOMBOID_FILE_CONFIG_INI:     ${ZOMBOID_FILE_CONFIG_INI}"
  echo "${INFO} ZOMBOID_FILE_CONFIG_SANDBOX: ${ZOMBOID_FILE_CONFIG_SANDBOX}"
  echo "${INFO} ZOMBOID_FILE_DB:             ${ZOMBOID_FILE_DB}"
}

# print_version prints versions.
function print_version() {
  echo "${INFO} pzlsm version ${VERSION}"
  echo "${INFO} gorcon version ${UTIL_RCON_VERSION}"
  echo "${INFO} range version ${UTIL_RANGE_VERSION}"
}

# strclear removes all spaces, quotation marks and tabs from a string.
function strclear() {
  local str=${1//\"/}; str=${str// /}; str=${str//$'\t'/}
  echo "${str}"
}

# is_updated checks the time of the last server update via steamcmd,
# compare it with the saved one, return a response about the need to
# restart if the time does not match and update the time in the repository
#
# TODO: Implement me.
function is_updated() {
  if [ ! -f "${ZOMBOID_MANIFEST}" ]; then
    echoerr "server manifest file not found"
    return 1
  fi

  # Get updated timestamp from manifest file.
  local updated=""
  updated=$(grep -oP "(?<=LastUpdated).*" "${ZOMBOID_MANIFEST}" | grep -o '[0-9]*')

  echo "false"
}

# install_range_builder downloads the regex-range-builder script and puts it
# in the utils directory.
function install_range_builder() {
  test -d "${UTIL_RANGE_DIR}" && echo "${UTIL_RANGE_DIR}" && return

  wget -P "${DIR_UTILS}" "${UTIL_RANGE_LINK}"
  tar -zxvf "${DIR_UTILS}/v${UTIL_RANGE_VERSION}.tar.gz" -C "${DIR_UTILS}"
  rm "${DIR_UTILS}/v${UTIL_RANGE_VERSION}.tar.gz"
}

# install_rcon downloads the rcon client and puts it in the utils directory.
function install_rcon() {
  test -d "${UTIL_RCON_DIR}" && echo "${UTIL_RCON_DIR}" && return

  wget -P "${DIR_UTILS}" "${UTIL_RCON_LINK}"
  tar -zxvf "${DIR_UTILS}/rcon-${UTIL_RCON_VERSION}-amd64_linux.tar.gz" -C "${DIR_UTILS}"
  rm "${DIR_UTILS}/rcon-${UTIL_RCON_VERSION}-amd64_linux.tar.gz"
}

# install_dependencies Installs the necessary dependencies to the server.
# You must have sudo privileges to call function install_dependencies.
# This is the only function in this script that needs root privileges.
# You can install dependencies yourself before running this script and do
# not call this function.
function install_dependencies() {
  # If a 64-bit version of the system is used, then 32-bit libraries must
  # be installed for SteamCMD.
  if [ "$(arch)" == "x86_64" ]; then
    apt-get install -y lib32gcc1
  fi

  apt-get install lib32gcc1

  # Update the C libraries for system calls.
  apt-get install -y libc6 libc6-dev libc6-dbg linux-libc-dev gcc

  # Install Java-SDK. It is required to run the Project Zomboid game server.
  apt-get install -y default-jdk

  # Install screen to run Project Zomboid in the background.
  apt-get install -y screen

  # To access the game database, you will need the sqlite3 library.
  apt-get install -y sqlite3

  # Install basic calculator.
  apt-get install -y bc

  # Install jq for json config parsing.
  apt-get install -y jq

  apt-get install -y net-tools

  apt-get install -y nmap
}

# fix_options changes game language to EN.
function fix_options() {
  sed -i -r "s/language=.*/language=EN/g" "${ZOMBOID_DIR}/options.ini"
}

# fix_args sets the home directory for the game, utf8 encoding, server name,
# game language, changes GC option.
# TODO: Add option for collecting GC logs.
# "-Xlog:gc*,gc+heap=debug,age*=debug:file=path/to/gc.out:time,uptime,level,tags:filesize=0:filecount=0"
function fix_args() {
  local arg_home=""
  arg_home=$(grep "Duser.home" "${SERVER_DIR}/ProjectZomboid64.json")
  [ "${arg_home}" ] && return 0

  # Set memory limit for JVM.
  sed -i -r "s/Xmx8g/Xmx${SERVER_MEMORY_LIMIT}m/g" "${SERVER_DIR}/ProjectZomboid64.json"

  # Change GC type.
  sed -i -r "s/UseZGC/UseG1GC/g" "${SERVER_DIR}/ProjectZomboid64.json"

  local set_home='"-Duser.home=.\/"'
  local set_encoding='"-Dfile.encoding=UTF-8"'
  local set_servername="\"-Dservername=${SERVER_NAME}\""
  local set_serverlang="\"-Duser.language=${SERVER_LANG}\""

  local indent="\r\n\t\t"
  local _search='"-Dzomboid.steam=1",'
  local _replace="${_search}${indent}${set_home},${indent}${set_encoding},${indent}${set_servername},${indent}${set_serverlang},"

  sed -i -r "s/${_search}/${_replace}/g" "${SERVER_DIR}/ProjectZomboid64.json"
}

# install_server installs Project Zomboid dedicated server.
# As arguments, you can pass validate and beta parameters in any order.
# If validate, the integrity and relevance of the current files will be checked.
# The beta parameter will download and install the game from the experimental
# IWBUMS branch. Only the latest stable and IWBUMS branches are supported.
function install_server() {
  local validate="${STEAMCMD_VALIDATE}"
  local beta="${STEAMCMD_BETA}"

  for arg in "$@"
  do
    case ${arg} in
      validate)
        validate="validate";;
      iwbums)
        beta="-beta iwillbackupmysave -betapassword iaccepttheconsequences";;
      unstable)
        beta="-beta unstable";;
    esac
  done

  # Create a directory for steamcmd and go to it. If the directory
  # already exists, no errors occur.
  mkdir -p "${HOME}/steamcmd" && cd "${HOME}/steamcmd" || return

  # Download steamcmd if it is not in the specified directory.
  if [ ! -f "steamcmd.sh" ]; then
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz &&
    tar -xvzf steamcmd_linux.tar.gz
    rm steamcmd_linux.tar.gz
  fi

  # Install Project Zomboid Server.
  ./steamcmd.sh +login "${STEAMCMD_USERNAME}" +force_install_dir "${SERVER_DIR}" +app_update ${APP_DEDICATED_ID} ${beta} ${validate} +exit

  # Return to the script directory.
  cd "${BASEDIR}" || return

  fix_options
  fix_args
}

# sync_config downloads config from github repo.
function sync_config() {
  if [ -z "${GITHUB_ACCESS_TOKEN}" ] || [ -z "${GITHUB_CONFIG_REPO}" ]; then
    echoerr "github repo or token is not set"; return 1
  fi

  local cfg_ini=""
  cfg_ini=$(curl -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" -s -L "${GITHUB_CONFIG_REPO}/${SERVER_NAME}/${SERVER_NAME}.ini")
  if [ "$(echo "${cfg_ini}" | wc -l)" -lt "100" ]; then
    echoerr "downloaded invalid ${SERVER_NAME}.ini";  return 1
  fi;

  local cfg_sand=""
  cfg_sand=$(curl -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" -s -L "${GITHUB_CONFIG_REPO}/${SERVER_NAME}/${SERVER_NAME}_SandboxVars.lua")
  if [ "$(echo "${cfg_sand}" | wc -l)" -lt "100" ]; then
    echoerr "downloaded invalid ${SERVER_NAME}_SandboxVars.lua";  return 1
  fi;

  local cfg_points=""
  cfg_points=$(curl -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" -s -L "${GITHUB_CONFIG_REPO}/${SERVER_NAME}/${SERVER_NAME}_spawnpoints.lua")
  if [ "$(echo "${cfg_points}" | wc -l)" -lt "7" ]; then
    echoerr "downloaded invalid ${SERVER_NAME}_spawnpoints.lua";  return 1
  fi;

  local cfg_regions=""
  cfg_regions=$(curl -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" -s -L "${GITHUB_CONFIG_REPO}/${SERVER_NAME}/${SERVER_NAME}_spawnregions.lua")
  if [ "$(echo "${cfg_regions}" | wc -l)" -lt "10" ]; then
    echoerr "downloaded invalid ${SERVER_NAME}_spawnregions.lua";  return 1
  fi;

  echo "${cfg_ini}" > "${ZOMBOID_FILE_CONFIG_INI}"
  echo "${cfg_sand}" > "${ZOMBOID_FILE_CONFIG_SANDBOX}"
  echo "${cfg_points}" > "${ZOMBOID_FILE_CONFIG_SPAWNPOINTS}"
  echo "${cfg_regions}" > "${ZOMBOID_FILE_CONFIG_SPAWNREGIONS}"

  echo "${OK} config downloaded"
}

# stats displays information on the peak processor consumption and
# current RAM consumption.
function stats() {
  local pid_zomboid=""
  pid_zomboid=$(pgrep -af ProjectZomboid64 | grep "servername ${SERVER_NAME}" | grep -o -e "^[0-9]*")
  if [ -z "${pid_zomboid}" ]; then
    echoerr "server is not running"; return 1
  fi

  local cpu=$(strclear "$(ps S -p "${pid_zomboid}" -o pcpu=)")

  local mem1=$(ps S -p "${pid_zomboid}" -o pmem=)
  local mem2=$(ps -ylp "${pid_zomboid}" | awk '{x += $8} END {print "" x/1024;}')

  local jvmres=$(jstat -gc "${pid_zomboid}")

  local jvm1=$(echo "${jvmres}" | awk 'NR>1 { printf("%.1f", $8/$7*100); }')
  local jvm2=$(echo "${jvmres}" | awk 'NR>1 { printf("%.2f", $8/1024); }')
  local jvm3=$(echo "${jvmres}" | awk 'NR>1 { printf("%.2f", $7/1024); }')

  local mem_used_percent=$((100*"${MEMORY_USED}"/"${MEMORY_AVAILABLE}"))

  local uptime=$(ps -p "${pid_zomboid}" -o etime | grep -v "ELAPSED" | xargs)

  echo "${INFO} cpu srv:  ${cpu}%"
  echo "${INFO} mem host: ${mem_used_percent}% (${MEMORY_USED} MB from ${MEMORY_AVAILABLE})"
  echo "${INFO} mem srv:  ${mem1}% (${mem2} MB)"
  echo "${INFO} mem jvm:  ${jvm1}% (${jvm2} MB from ${jvm3} MB)"
  echo "${INFO} uptime:   ${uptime}"
}

# screencmd calls the $1 command to the game using screen util.
# The screencmd function is faster than rconcmd, but you cannot get a response
# to the request. Therefore, it should be used when the answer is not needed.
function screencmd() {
  local command="$1"
  [ -z "${command}" ] && { echoerr "command is not set"; return 1; }

  screen -S "${SCREEN_ZOMBOID}" -X stuff "${command}\r"
}

# rconcmd calls the $1 command to the game using Source RCON Protocol.
# The port and authorization parameters takes from the Project Zomboid config.
function rconcmd() {
  local command="$1"
  [ -z "${command}" ] && { echoerr "command is not set"; return 1; }

  local host='127.0.0.1'
  local port=""
  local password=""

  port=$(grep "RCONPort=" "${ZOMBOID_FILE_CONFIG_INI}"); port=${port//RCONPort=/}; port=${port// /}
  password=$(grep "RCONPassword=" "${ZOMBOID_FILE_CONFIG_INI}"); password=${password//RCONPassword=/}; password=${password// /}

  ${UTIL_RCON_FILE} -a "${host}:${port}" -p "${password}" -c "${command}"
}

# kickusers kicks all players from the server.
function kickusers() {
  local players=""
  players=$(rconcmd "players")
  [ $? -ne 0 ] && { echoerr "kickusers: cannot get users"; return 1; }

  local i=0

  players=$(echo "${players}" | grep ^"-")
  if [ "${players}" ]; then
    IFS=$'\n'

    declare -a a
    a=("${players}")

    for line in "${a[@]}"; do
      ((i=i+1))
      local username="${line:1}"
      screencmd "kickuser \"${username}\""
    done
  fi

  echo "${OK} kicked ${i} users"
}

# start starts the server in a screen window.
# An error message will be displayed if server has been started earlier.
function start() {
  echo "${OK} starting the server..."

  local pid_screen
  pid_screen=$(ps aux | grep -v grep | grep -i "screen -U -mdS ${SCREEN_ZOMBOID} " | awk '{print $2}')
  if [ -n "${pid_screen}" ]; then
    echo "${INFO} server already started"; return 0
  fi

  screen -wipe > /dev/null 2>&1; sleep 1s
  env LANG=ru_RU.utf8 screen -U -mdS "${SCREEN_ZOMBOID}" "${SERVER_DIR}/start-server.sh" -servername "${SERVER_NAME}"

  if [ ! $? -eq 0  ]; then
    echoerr "server is not started"; return 1
  fi

  if [ "$1" == "first" ] && [ -n "${FIRST_RUN_ADMIN_PASSWORD}" ]; then
    sleep 1s && screencmd "${FIRST_RUN_ADMIN_PASSWORD}"
    sleep 1s && screencmd "${FIRST_RUN_ADMIN_PASSWORD}"
  fi
}

# stop stops the server.
function stop() {
  echo "${INFO} stopping the server..."

  local pid_screen
  pid_screen=$(ps aux | grep -v grep | grep -i "screen -U -mdS ${SCREEN_ZOMBOID} " | awk '{print $2}')
  if [ -z "${pid_screen}" ]; then
    echoerr "server already stopped"; return 0
  fi

  # kickusers is used for fix a game bug.
  # When `quit` game command is executed, there is no log record the fact
  # that the players was exit the game. If you make a forced kick from the
  # server, then the log entry appears correctly.
  kickusers

  sleep 1s

  if ! screencmd 'quit'; then
    echoerr "server is not stopped correctly"
  fi

  # If after a regular shutdown server remains running, we must forcibly stop it.
  sleep 20s

  pid_screen=$(ps aux | grep -v grep | grep -i "screen -U -mdS ${SCREEN_ZOMBOID} " | awk '{print $2}')
  if [ -n "${pid_screen}" ]; then
    echo "${INFO} kill screen process ${pid_screen}"
    kill "${pid_screen}" > /dev/null 2>&1; sleep 1s
  fi

  echo "${OK} server is stopped"

  if [ "$1" == "fix" ] || [ "$2" == "fix" ]; then
    delete_mods_manifest
  fi

  if [ "$1" == "now" ] || [ "${BACKUP_ON_STOP}" != "true" ]; then
    return 0
  fi

  # After a stopping the server invokes the function of cleaning garbage that
  # the game generates during its operation.
  delete_old_chunks
  delete_old_logs
  delete_old_java_stack_traces "${CLEAR_STACK_TRACE_DAY}"

  # Backups
  backup
}

# restart stops the server and starts it after 10 seconds.
function restart() {
  echo "${INFO} restarting the server..."

  stop "$1" "$2"
  sleep 10s
  start
}

# shutdown_wrapper triggers informational messages for players to alert them of
# impending server shutdown. After 5 minutes, it calls the stop or restart
# function.
function shutdown_wrapper() {
  local pid_screen
  pid_screen=$(ps aux | grep -v grep | grep -i "screen -U -mdS ${SCREEN_ZOMBOID} " | awk '{print $2}')
  if [ -z "${pid_screen}" ]; then
    echoerr "server already stopped"
    return 0
  fi

  function ticker() {
    local msg=$1

    if [ "$2" != "now" ]; then
      echo "${INFO} ${msg} 5 minutes"
      screencmd "servermsg \"${msg} 5 minutes\""

      sleep 240s

      echo "${INFO} ${msg} 1 minute";
      screencmd "servermsg \"${msg} 1 minute\""

      sleep 50s
    fi

    echo "${INFO} ${msg} 10 seconds";
    screencmd "servermsg \"${msg} 10 seconds\""

    sleep 5s
    t=5
    while [ ${t} -gt 0 ]; do
      screencmd "servermsg \"${msg} ${t} seconds\""
      sleep 1s
      ((t=t-1))
    done
  }

  case "$1" in
    stop)
      ticker "Stopping the server in" "$2"
      stop "$2" "$3"
      ;;
    restart)
      ticker "Restarting the server in" "$2"
      restart "$2" "$3"
      ;;
    *)
      echoerr "wrong shutdown command: $1"
      return 1
      ;;
  esac
}

# delete_mods_manifest deletes appworkshop_108600.acf file. It need to
# update mods correctly.
function delete_mods_manifest() {
  [ ! -f "${ZOMBOID_MODS_MANIFEST}" ] && return 0

  echo "${INFO} remove appworkshop_${APP_ID}.acf"
  rm "${ZOMBOID_MODS_MANIFEST}"
}

# delete_zombies deletes all zpop_*_*.bin files from Zomboid/Saves directory.
# These files are responsible for placing zombies on the world.
# It is recommended to use with a turned off server. When used on a running
# server, it can create more problems than it solves.
# But it can help the game restart the threads responsible for the zombies,
# if they freeze.
function delete_zombies() {
  local count
  count=$(find "${ZOMBOID_DIR_MAP}" -name "zpop_*_*.bin" | wc -l)
  echo "${INFO} remove zpop_*_*.bin files... ${count} files"
  rm -rf "${ZOMBOID_DIR_MAP}/zpop_*_*.bin"
}

# delete_old_chunks deletes files map_*_*.bin older than $1 days from
# Zomboid/Saves directory.
# If you do not pass the number of days $1, or pass the value 0 then the
# default value will be taken from the variable CLEAR_MAP_DAY.
function delete_old_chunks() {
  local days="$1"
  [ -z "${days}" ] && days=${CLEAR_MAP_DAY}

  # Do nothing if turned off in the settings.
  [ "${days}" -eq "0" ] && return 0

  local count
  count=$(find "${ZOMBOID_DIR_MAP}" -name "map_*_*.bin" -mtime +${days} | wc -l)
  echo "${INFO} remove chunks older than ${days} days... ${count} chunks"
  find "${ZOMBOID_DIR_MAP}" -name "map_*_*.bin" -mtime +${days} -delete
}

# delete_old_logs deletes log files that are older than $1 days from
# Zomboid/Logs directory.
# If you do not pass the number of days $1, or pass the value 0 then the
# default value will be taken from the variable CLEAR_LOGS_DAY.
function delete_old_logs() {
  local days="$1"
  [ -z "${days}" ] && days=${CLEAR_LOGS_DAY}

  # Do nothing if turned off in the settings.
  [ "${days}" -eq "0" ] && return 0

  # Remove old logs folders.
  local count=$(find "${ZOMBOID_DIR_LOGS}" -name "*.txt" -mtime +${days} | wc -l)
  echo "${INFO} remove logs files older than ${days} days... ${count} files"
  find "${ZOMBOID_DIR_LOGS}" -name "*.txt" -mtime +${days} -delete

  # Remove empty logs folders.
  find "${ZOMBOID_DIR_LOGS}" -empty -type d -delete
}

# delete_old_java_stack_traces deletes hs_err_pid*.log files that are older
# than $1 days from server root directory.
# If you do not pass the number of days $1, or pass the value 0 then the
# default value will be taken from the variable CLEAR_STACK_TRACE_DAY.
function delete_old_java_stack_traces() {
  local days="$1"
  [ -z "${days}" ] && days=${CLEAR_STACK_TRACE_DAY}

  # Do nothing if turned off in the settings.
  [ "${days}" -eq "0" ] && return

  # Remove java stack traces.
  local count=$(find ${SERVER_DIR} -name "hs_err_pid*.log" -mtime +${days} | wc -l)
  echo "${INFO} remove hs_err_pid*.log files older than ${days} days... ${count} files"
  find ${SERVER_DIR} -name "hs_err_pid*.log" -mtime +${days} -delete
}

# delete_old_backups deletes files zomboid_*_*.tar.gz older than $1 days from
# backups/server directory.
# If you do not pass the number of days $1, or pass the value 0 then the
# default value will be taken from the variable CLEAR_BACKUPS_DAY.
function delete_old_backups() {
  local days="$1"
  [ -z "${days}" ] && days=${CLEAR_BACKUPS_DAY}

  # Do nothing if turned off in the settings.
  [ "${days}" -eq "0" ] && return 0

  local count=$(find "${DIR_BACKUPS}/server" -name "zomboid_*_*.tar.gz" -mtime +${days} | wc -l)
  echo "${INFO} remove backups older than ${days} days... ${count} backups"
  find "${DIR_BACKUPS}/server" -name "zomboid_*_*.tar.gz" -mtime +${days} -delete
}

# delete_old_players deletes files players_*_*.db older than $1 days from
# backups/server/payers directory.
# If you do not pass the number of days $1, or pass the value 0 then the
# default value will be taken from the variable CLEAR_TIME_MACHINE_DAY.
function delete_old_players() {
  local days="$1"
  [ -z "${days}" ] && days=${CLEAR_TIME_MACHINE_DAY}

  # Do nothing if turned off in the settings.
  [ "${days}" -eq "0" ] && return 0

  local count=$(find "${DIR_BACKUPS}/server/players" -name "players_*_*.db" -mtime +${days} | wc -l)
  echo "${INFO} remove players backups older than ${days} days... ${count} backups"
  find "${DIR_BACKUPS}/server/players" -name "players_*_*.db" -mtime +${days} -delete
}

# get_rectangle takes the coordinates of the upper right and lower left points
# and builds a rectangular area of chunks from them.
function get_rectangle() {
  local from="$1"
  if [ -z "${from}" ]; then
     echoerr "upper right corner is not set"
     echo "0 0 0 0"; return 1
  fi

  local to="$2"
  if [ -z "${to}" ]; then
     echoerr "lower left corner is not set"
     echo "0 0 0 0"; return 1
  fi

  local regexp='^[0-9]+$'

  # Upper right corner.
  IFS='x' read -ra point_top <<< "${from}"
  local top_x="${point_top[0]}"
  local top_y="${point_top[1]}"
  if ! [[ ${top_x} =~ $regexp ]] || ! [[ ${top_y} =~ $regexp ]]; then
     echoerr "upper right corner is invalid"
     echo "0 0 0 0"; return 1
  fi

  # Lower left corner.
  IFS='x' read -ra point_bot <<< "${to}"
  local bot_x="${point_bot[0]}";
  local bot_y="${point_bot[1]}"
  if ! [[ ${bot_x} =~ $regexp ]] || ! [[ ${bot_y} =~ $regexp ]]; then
     echoerr "lower left corner is invalid"
     echo "0 0 0 0"; return 1
  fi

  echo "${top_x} ${top_y} ${bot_x} ${bot_y}"
}

# map_regen takes the coordinates of the upper right and lower left points
# and builds a rectangular area of chunks from them and deletes them.
#
# Example: map_regen 10626x10600 10679x10661
function map_regen() {
  local from="$1"
  local to="$2"
  local rectangle=($(get_rectangle "${from}" "${to}"))

  # Delete last digit to convert to chunk name.
  local top_x=$(echo "${rectangle[0]}/10" |bc)
  local top_y=$(echo "${rectangle[1]}/10" |bc)
  local bot_x=$(echo "${rectangle[2]}/10" |bc)
  local bot_y=$(echo "${rectangle[3]}/10" |bc)

  if [ "${top_x}" -ge "${bot_x}" ] || [ "${top_y}" -ge "${bot_y}" ]; then
     echoerr "invalid points"
     return 1
  fi

  local count=0
  local count_success=0
  for (( x=top_x; x <= bot_x; x++ )) do
    for (( y=top_y; y <= bot_y; y++ )) do
      let count++
      local name="map_${x}_${y}.bin"
      rm ${ZOMBOID_DIR_MAP}/${name} > /dev/null 2>&1
      if [ $? -eq 0 ]; then
        let count_success++
      fi
    done
  done

  echo "${OK} deleted ${count_success} from ${count} chunks"
}

# map_copy takes the coordinates of the upper right and lower left points
# and builds a rectangular area of chunks from them and copies them to
# backups/copy directory. With an additional argument, you can specify a name
# for the catalog of copied chunks. If you specify a name, then it will be
# generated based on the coordinates.
#
# Example: map_copy 11586x8230 11639x8321
# Example: map_copy 11586x8230 11639x8321 bar
function map_copy() {
  local from="$1"
  local to="$2"
  local rectangle=($(get_rectangle "${from}" "${to}"))

  # Delete last digit to convert to chunk name.
  local top_x=$(echo "${rectangle[0]}/10" |bc)
  local top_y=$(echo "${rectangle[1]}/10" |bc)
  local bot_x=$(echo "${rectangle[2]}/10" |bc)
  local bot_y=$(echo "${rectangle[3]}/10" |bc)

  if [ "${top_x}" -ge "${bot_x}" ] || [ "${top_y}" -ge "${bot_y}" ]; then
     echoerr "invalid points"
     return 1
  fi

  local copy_path="${DIR_BACKUPS}/copy"
  if [ -z "$3" ]; then
    copy_path=${copy_path}/${NOW}_${from}_${to}
  else
    copy_path=${copy_path}/${NOW}_$3
  fi

  mkdir -p ${copy_path} #> /dev/null 2>&1
  if [ ! $? -eq 0 ]; then
    echoerr "can not create directory ${copy_path} to copy"
    return 1
  fi

  local count=0
  local count_success=0
  for (( x=top_x; x <= bot_x; x++ )) do
    for (( y=top_y; y <= bot_y; y++ )) do
      let count++
      local name="map_${x}_${y}.bin"
      cp ${ZOMBOID_DIR_MAP}/${name} ${copy_path} > /dev/null 2>&1
      if [ $? -eq 0 ]; then
        let count_success++
      else
        echoerr "can not copy chunk ${name}"
      fi
    done
  done

  echo "${OK} copied ${count_success} from ${count} chunks"
}

# map_copyto takes the coordinates of the upper right and lower left points
# and builds a rectangular area of chunks from them and copies them to
# backups/copy directory and rename to new coordinates. With an additional
# argument, you can specify a name for the catalog of copied chunks. If you
# specify a name, then it will be generated based on the coordinates.
#
# Example: map_copyto 9240x4800 9299x4859 11530x8200
# Example: map_copyto 9240x4800 9299x4859 11530x8200 maze
function map_copyto() {
  local from="$1"
  local to="$2"
  local rectangle=($(get_rectangle "${from}" "${to}"))

  # Delete last digit to convert to chunk name.
  local top_x=$(echo "${rectangle[0]}/10" |bc)
  local top_y=$(echo "${rectangle[1]}/10" |bc)
  local bot_x=$(echo "${rectangle[2]}/10" |bc)
  local bot_y=$(echo "${rectangle[3]}/10" |bc)

  if [[ "${top_x}" -ge "${bot_x}" ]] || [[ "${top_y}" -ge "${bot_y}" ]]; then
     echoerr "invalid points"
     return 1
  fi

  local from_new="$3"
  local regexp='^[0-9]+$'

  IFS='x' read -ra point_top <<< "${from_new}"
  local top_x_new=$(echo "${point_top[0]}/10" |bc)
  local top_y_new=$(echo "${point_top[1]}/10" |bc)

  if ! [[ ${top_x_new} =~ $regexp ]] || ! [[ ${top_y_new} =~ $regexp ]]; then
     echoerr "upper new point is invalid"
     return 1
  fi

  local copy_path="${DIR_BACKUPS}/copy"
  if [[ -z "$4" ]]; then
    copy_path="${copy_path}/${NOW}_${from_new}"
  else
    copy_path="${copy_path}/${NOW}_$4"
  fi

  mkdir -p "${copy_path}" #> /dev/null 2>&1
  if [[ ! $? -eq 0 ]]; then
    echoerr "can not create directory ${copy_path} to copy"
    return 1
  fi

  local x_new="${top_x_new}"

  local count=0
  local count_success=0
  for (( x=top_x; x <= bot_x; x++ )) do
    local y_new="${top_y_new}"

    for (( y=top_y; y <= bot_y; y++ )) do
      let count++

      local name="map_${x}_${y}.bin"
      local name_new="map_${x_new}_${y_new}.bin"

      cp "${ZOMBOID_DIR_MAP}/${name}" "${copy_path}/${name_new}" > /dev/null 2>&1
      if [[ $? -eq 0 ]]; then
        let count_success++
      else
        echoerr "can not copy chunk ${name}"
      fi

      let y_new++
    done

    let x_new++
  done

  echo "${OK} copied ${count_success} from ${count} chunks"
}

# range takes the coordinates of the upper right and lower left points
# and builds a rectangular area of chunks from them for generating regexp rule
# for searching the log.
#
# Example range 4251x5869 4270x5884
# > (425[1-9]|426[0-9]|4270),(5869|587[0-9]|588[0-4])
function range() {
  if [ ! -f "${UTIL_RANGE_FILE}" ]; then
     echoerr "util range.sh is not found"; return 1
  fi

  local from="$1"
  local to="$2"
  local rectangle=($(get_rectangle "${from}" "${to}"))

  local top_x=$(echo "${rectangle[0]}" |bc)
  local top_y=$(echo "${rectangle[1]}" |bc)
  local bot_x=$(echo "${rectangle[2]}" |bc)
  local bot_y=$(echo "${rectangle[3]}" |bc)

  if [ "${top_x}" -ge "${bot_x}" ] || [ "${top_y}" -ge "${bot_y}" ]; then
     echoerr "invalid points"; return 1
  fi

  local range_x=$(${UTIL_RANGE_FILE} "${top_x}" "${bot_x}")
  local range_y=$(${UTIL_RANGE_FILE} "${top_y}" "${bot_y}")

  echo "${range_x},${range_y}"
}

# backup copies server files to backup/server directory.
# TODO: Refactor backup function.
# After successful copying, check for old backups and delete them.
function backup() {
  NOW=$(date "+%Y%m%d_%H%M%S")

  local btype="$1"
  local backup_path="${DIR_BACKUPS}/server"
  local backup_players_path="${DIR_BACKUPS}/server/players"

  mkdir -p "${backup_path}" #> /dev/null 2>&1
  if [ ! $? -eq 0 ]; then
    echoerr "can not create directory ${backup_path} to backup"; return 1
  fi

  mkdir -p "${backup_players_path}" #> /dev/null 2>&1
  if [ ! $? -eq 0 ]; then
    echoerr "can not create directory ${backup_players_path} to backup"; return 1
  fi

  if [ "${btype}" == "players" ]; then
    echo "${INFO} backup zomboid players..."

    local name="players_${NOW}.db"
    cp "${ZOMBOID_DIR_MAP}/players.db" "${backup_players_path}/${name}"
    if [ $? -eq 0 ]; then
      echo "${OK} backup ${name} created successful"
      delete_old_players "${CLEAR_TIME_MACHINE_DAY}"
    fi

    return 0
  fi

  echo "${INFO} backup zomboid files..."

  local name="zomboid_${NOW}.tar.gz"
  tar -czf "${backup_path}/${name}" -P --warning=no-file-changed "${ZOMBOID_DIR}"
  if [ ! $? -eq 0 ]; then
    echoerr "backup not created"; return 1
  fi

  echo "${OK} backup ${name} created successful"
  delete_old_backups "${CLEAR_BACKUPS_DAY}"
}

# log_search looks for string $1 in log files. Chat logs excluded from search.
# Using the optional parameter $2, you can specify the name of the log file to
# search.
#
# Example: log_search outdead
# Example: log_search outdead user
# Example: log_search outdead user connected
function log_search() {
  if [ -z "$1" ]; then
     echoerr "search param is not set"; return 1
  fi

  local filename="$2"
  if [ -z "${filename}" ]; then
    #grep --exclude=*_chat.txt -rIah -E "$1" "${ZOMBOID_DIR_LOGS}" | sort -b -k1.8,1.9 -k1.5,1.6 -k1.2,1.3
    grep --exclude=*_chat.txt --exclude=*_DebugLog-server.txt -rIah -E "$1" "${ZOMBOID_DIR_LOGS}" | sort -b -k1.8,1.9 -k1.5,1.6 -k1.2,1.3

    return 0
  fi

  local action="$3"
  if [ -z "${action}" ]; then
    grep --include=*_"${filename}".txt -rIah -E "$1" "${ZOMBOID_DIR_LOGS}" | sort -b -k1.8,1.9 -k1.5,1.6 -k1.2,1.3

    return 0
  fi

  local limit="$4"
  if [ -n "${limit}" ]; then
    grep --include=*_"${filename}".txt -rIah -E "$1\"? ${action}" "${ZOMBOID_DIR_LOGS}" | sort -b -k1.8,1.9 -k1.5,1.6 -k1.2,1.3 | tail -n "${limit}"
  else
    grep --include=*_"${filename}".txt -rIah -E "$1\"? ${action}" "${ZOMBOID_DIR_LOGS}" | sort -b -k1.8,1.9 -k1.5,1.6 -k1.2,1.3
  fi
}

# clog_search looks for string $1 in current log files. Chat logs excluded from search.
# Using the optional parameter $2, you can specify the name of the log file to
# search.
#
# Example: log_search outdead
# Example: log_search outdead user
# Example: log_search outdead user connected
function clog_search() {
  if [ -z "$1" ]; then
     echoerr "search param is not set"; return 1
  fi

  local filename="$2"
  if [ -z "${filename}" ]; then
    find "${ZOMBOID_DIR_LOGS}" -maxdepth 1 -type f -not -iname "*_DebugLog-server.txt" -not -iname "*_chat.txt" -exec grep "$1" {} \; | sort

    return 0
  fi

  local action="$3"
  if [ -z "${action}" ]; then
    find "${ZOMBOID_DIR_LOGS}" -maxdepth 1 -type f -iname "*_${filename}.txt" -exec grep "$1" {} \; | sort

    return 0
  fi

  local limit="$4"
  if [ -n "${limit}" ]; then
    find "${ZOMBOID_DIR_LOGS}" -maxdepth 1 -type f -iname "*_${filename}.txt" -exec grep -E "$1\"? ${action}" {} \; | tail -n "${limit}" | sort
  else
    find "${ZOMBOID_DIR_LOGS}" -maxdepth 1 -type f -iname "*_${filename}.txt" -exec grep -E "$1\"? ${action}" {} \; | sort
  fi
}

# fn_sqlite fulfills query $1 to the Project Zomboid database and displays its
# result.
#
# Example: fn_sqlite 'select * from whitelist limit 1'
function fn_sqlite() {
  local query="$1"
  if [ -z "${query}" ]; then
     echoerr "query param is not set"; return 1
  fi

  sqlite3 "${ZOMBOID_FILE_DB}" "${query}"
}

# restore_players replaces players.db database from backup.
function restore_players() {
  local filename="$1"
  if [ -z "${filename}" ]; then
     echoerr "filename param is not set"; return 1
  fi

  local path="${DIR_BACKUPS}/server/players/${filename}"
  if [ ! -f "${path}" ]; then
    echoerr "players backup ${filename} does not exist"; return 1
  fi

  local pid_screen=$(ps aux | grep -v grep | grep -i "screen -U -mdS ${SCREEN_ZOMBOID} " | awk '{print $2}')
  if [ -n "${pid_screen}" ]; then
    echoerr "cannot be executed on a running server"; return 1
  fi

  cp "${path}" "${ZOMBOID_DIR_MAP}/players.db" > /dev/null 2>&1
  if [ ! $? -eq 0 ]; then
    echoerr "players backup ${filename} was not restored"; return 1
  fi

  echo "${OK} players backup ${filename} restored successful"
}

# public creates public symlinks.
function public() {
  mkdir -p "${DIR_PUBLIC}"
  mkdir -p "${DIR_PUBLIC}/saves"

  ln -sf "${DIR_BACKUPS}" "${DIR_PUBLIC}/backups"
  ln -sf "${ZOMBOID_DIR_LOGS}}" "${DIR_PUBLIC}/logs"
}

# main contains a proxy for entering permissible functions.
function main() {
  case "$1" in
    version)
      print_version
      ;;
    variables)
      print_variables
      ;;
    prepare)
      install_dependencies
      ;;
    get_utils)
      install_range_builder
      install_rcon
      ;;
    install)
      install_server "$2" "$3"
      ;;
    sync)
      sync_config
      ;;
    info)
      stats
      ;;
    start)
      start "$2"
      ;;
    stop)
      shutdown_wrapper "stop" "$2" "$3"
      ;;
    restart)
      shutdown_wrapper "restart" "$2" "$3"
      ;;
    kickusers)
      kickusers
      ;;
    rcon)
      rconcmd "$2"
      ;;
    screen)
      screencmd "$2"
      ;;
    log_clear)
      delete_old_logs "$2"
      ;;
    map_clear)
      delete_old_chunks "$2"
      ;;
    map_copy)
      map_copy "$2" "$3" "$4"
      ;;
    map_copyto)
      map_copyto "$2" "$3" "$4" "$5"
      ;;
    map_regen)
      map_regen "$2" "$3"
      ;;
    delete_zombies)
      delete_zombies
      ;;
    delete_manifest)
      delete_mods_manifest
      ;;
    backup)
      backup "$2"
      ;;
    log)
      log_search "$2" "$3" "$4" "$5"
      ;;
    clog)
      clog_search "$2" "$3" "$4" "$5"
      ;;
    sql)
      fn_sqlite "$2"
      ;;
    range)
      local bottom="$3"
      if [ "${bottom}" == "-" ]; then
        bottom=$4
      fi

      range "$2" "${bottom}"
      ;;
    fix)
      fix_options
      fix_args
      ;;
    restore_players)
      restore_players "$2"
      ;;
    public)
      public
      ;;
  esac
}

if [ -z "$1" ]; then
  echo "${INFO} Permissible commands:"
  echo "........ version"
  echo "........ variables"
  echo "........ prepare"
  echo "........ get_utils"
  echo "........ install {validate beta}"
  echo "........ sync"
  echo "........ info"
  echo "........ start [first]"
  echo "........ stop [now] [fix]"
  echo "........ restart [now] [fix]"
  echo "........ kickusers"
  echo "........ rcon 'command'"
  echo "........ screen 'command'"
  echo "........ log_clear [int]"
  echo "........ map_clear [int]"
  echo "........ map_copy {top} {bottom} [name]"
  echo "........ map_copyto top bottom top_new bottom_new [name]"
  echo "........ map_regen {top} {bottom}"
  echo "........ range {top} {bottom}"
  echo "........ zombie_delete"
  echo "........ delete_manifest"
  echo "........ backup [type]"
  echo "........ logpvp"
  echo "........ log {search} [type] [action] [limit]"
  echo "........ clog {search} [type] [action] [limit]"
  echo "........ sql {query}"
  echo "........ fix"
  echo "........ restore_players {filename}"
  echo "........ public"
  printf "[  >>  ] " & read CMD
fi

if [ -n "$CMD" ]; then
  IFS=' ' read -ra args <<< "${CMD}"
  main "${args[@]}"
else
  main "$@"
fi
