#!/bin/bash

# Project Zomboid Linux Server Manager.
#
# Copyright (c) 2019 Pavel Korotkiy (outdead).
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
VERSION="0.19.1"

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

# Project Zomboid Dedicated Server App ID in Steam.
APP_ID=380870

# SCREEN_ZOMBOID contains the name of the screen to launch Project Zomboid.
SCREEN_ZOMBOID="zomboid"

# NOW is the current date and time in default format Y%m%d_%H%M%S.
# You can change format in config file.
NOW=$(date "+%Y%m%d_%H%M%S")

# TIMESTAMP is current timestamp.
TIMESTAMP=$(date "+%s")

# Linux Server Manager directories definitions.
BASEDIR=$(dirname "$(readlink -f "$BASH_SOURCE")")
DIR_BACKUPS="${BASEDIR}/backups"
DIR_UTILS="${BASEDIR}/utils"
DIR_INCLUDE="${BASEDIR}/include"
DIR_PZLSM_CONFIG="${DIR_INCLUDE}/config/pzlsm"

# Linux Server Manager files definitions.
FILE_PZLSM_LOG="${BASEDIR}/server.log"
FILE_PZLSM_CONFIG_DEFAULT="${DIR_PZLSM_CONFIG}/default.sh"
FILE_PZLSM_CONFIG_LOCAL="${DIR_PZLSM_CONFIG}/local.sh"
FILE_PZLSM_UPDATE="${BASEDIR}/server.update"

# Import config files if exists.
# shellcheck source=include/config/default.sh
test -f "${FILE_PZLSM_CONFIG_DEFAULT}" && . "${FILE_PZLSM_CONFIG_DEFAULT}"
# shellcheck source=include/config/local.sh
test -f "${FILE_PZLSM_CONFIG_LOCAL}" && . "${FILE_PZLSM_CONFIG_LOCAL}"

## Check config variables and set default values if not defined.
[ -z "${CLEAR_MAP_DAY}" ] && CLEAR_MAP_DAY=21
[ -z "${CLEAR_LOGS_DAY}" ] && CLEAR_LOGS_DAY=1000
[ -z "${CLEAR_STACK_TRACE_DAY}" ] && CLEAR_STACK_TRACE_DAY=1000
[ -z "${CLEAR_BACKUPS_DAY}" ] && CLEAR_BACKUPS_DAY=1000
[ -z "${UTIL_RANGE_VERSION}" ] && UTIL_RANGE_VERSION="1.0.0"
[ -z "${UTIL_RCON_VERSION}" ] && UTIL_RCON_VERSION="0.4.0"
[ -z "${SERVER_MEMORY_LIMIT}" ] && SERVER_MEMORY_LIMIT=2048
[ -z "${SERVER_NAME}" ] && SERVER_NAME="servertest"
[ -z "${SERVER_DIR}" ] && SERVER_DIR="${HOME}/pz/server"
[ -z "${ZOMBOID_DIR}" ] && ZOMBOID_DIR="${SERVER_DIR}/Zomboid"
[ -z "${FIRST_RUN_ADMIN_PASSWORD}" ] && FIRST_RUN_ADMIN_PASSWORD="changeme"

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
ZOMBOID_FILE_DB="${ZOMBOID_DIR_DB}/${SERVER_NAME}.db"

# echoerr prints error message to stderr and FILE_PZLSM_LOG file.
function echoerr() {
  #>&2 echo "${ER} $1"
  echo "${ER} $1"
  echo "[$(date "+%Y-%m-%d %H:%M:%S")] $0 - $1" >> "${FILE_PZLSM_LOG}"
}

# print_variables prints pzlsm variables.
function print_variables() {
  echo "${INFO} MEMORY_AVAILABLE:            ${MEMORY_AVAILABLE}"
  echo "${INFO} MEMORY_USED:                 ${MEMORY_USED}"
  echo "${INFO} CPU_CORE_COUNT:              ${CPU_CORE_COUNT}"
  echo "${INFO} APP_ID:                      ${APP_ID}"
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
# TODO: Consider about better implementation via Steam.
function is_updated() {
  local manifest="${SERVER_DIR}/steamapps/appmanifest_${APP_ID}.acf"
  if [ ! -f "${manifest}" ]; then
    echo "false"
    echoerr "server manifest file not found"
    return 1
  fi

  # Get updated timestamp from manifest file.
  local updated=$(grep -oP "(?<=LastUpdated).*" "${manifest}" | grep -o '[0-9]*')

  # Get stored updated timestamp and compare with updated from manifest.
  local storage="${FILE_PZLSM_UPDATE}"
  if [ -f "${storage}" ]; then
    local updated_stored=$(cat "${storage}")
    if [ "${updated_stored}" ] && [ "${updated_stored}" == "${updated}" ]; then
      echo "false"
      return 0
    fi
  fi

  # Save updated timestamp to local storage.
  echo "${updated}" > "${storage}"
  echo "true"
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
}

# install_server installs Project Zomboid dedicated server.
# As arguments, you can pass validate and beta parameters in any order.
# If validate, the integrity and relevance of the current files will be checked.
# The beta parameter will download and install the game from the experimental
# IWBUMS branch. Only the latest stable and IWBUMS branches are supported.
function install_server() {
  local platform="linux"
  local username="anonymous"

  local validate=""
  local beta=""

  for arg in "$@"
  do
    case ${arg} in
      validate)
        validate="validate";;
      iwbums)
        beta="-beta iwillbackupmysave -betapassword iaccepttheconsequences";;
      41mptest)
        beta="-beta b41multiplayer";;
    esac
  done

  # Create a directory for steamcmd and go to it. If the directory
  # already exists, no errors occur.
  mkdir -p "${HOME}/steamcmd" && cd "${HOME}/steamcmd"

  # Download steamcmd if it is not in the specified directory.
  if [ ! -f "steamcmd.sh" ]; then
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz &&
    tar -xvzf steamcmd_linux.tar.gz
    rm steamcmd_linux.tar.gz
  fi

  # Install Project Zomboid Server.
  ./steamcmd.sh +login "${username}" +force_install_dir "${SERVER_DIR}" +app_update ${APP_ID} ${beta} ${validate} +exit

  local manifest="${SERVER_DIR}/steamapps/appmanifest_${APP_ID}.acf"
  local updated=$(grep -oP "(?<=LastUpdated).*" "${manifest}" | grep -o '[0-9]*')

  # Return to the script directory.
  cd ${BASEDIR}

  # Sett memory limit for JVM.
  # TODO: Put in a function and make it customizable depending on the received arguments.
  sed -i -r "s/Xms2048m/Xms${SERVER_MEMORY_LIMIT}m/g" "${SERVER_DIR}/ProjectZomboid64.json"
  sed -i -r "s/Xmx2048m/Xmx${SERVER_MEMORY_LIMIT}m/g" "${SERVER_DIR}/ProjectZomboid64.json"

  # Sett the home directory for the game, utf8 encoding and server name.
  local arg_home=$(grep "Duser.home" "${SERVER_DIR}/ProjectZomboid64.json")
  if [ ! "${arg_home}" ]; then
    local indent="\r\n\t\t"

    local set_home='"-Duser.home=.\/"'
    local set_encoding='"-Dfile.encoding=UTF-8"'
    local set_servername="\"-Dservername=${SERVER_NAME}\""

    local _search='"-Dzomboid.steam=1",'
    local _replace="${_search}${indent}${set_home},${indent}${set_encoding},${indent}${set_servername},"

    sed -i -r "s/${_search}/${_replace}/g" "${SERVER_DIR}/ProjectZomboid64.json"
  fi

  # Check that the server has been installed and save the time of the last update.
  # TODO: implement me.
  # is_updated
}

# stats displays information on the peak processor consumption and
# current RAM consumption.
function stats() {
  local pid_zomboid
  if [ "$(pgrep -af ProjectZomboid64 | wc -l)" == "1" ]; then
    pid_zomboid=$(pidof ProjectZomboid64)
  else
    pid_zomboid=$(pgrep -af ProjectZomboid64 | grep "servername ${SERVER_NAME}" | grep -o -e "^[0-9]*")
  fi
  if [ -z "${pid_zomboid}" ]; then
    echoerr "server is not running"
    return 1
  fi

  local cpu=$(strclear "$(ps S -p "${pid_zomboid}" -o pcpu=)")
  local mem1=$(ps S -p "${pid_zomboid}" -o pmem=)
  local mem2=$(ps -ylp "${pid_zomboid}" | awk '{x += $8} END {print "" x/1024;}')

  local jvmres=$(jstat -gc "${pid_zomboid}")

  local jvm1=$(echo "${jvmres}" | awk 'NR>1 { printf("%.1f", $8/$7*100); }')
  local jvm2=$(echo "${jvmres}" | awk 'NR>1 { printf("%.2f", $8/1024); }')
  local jvm3=$(echo "${jvmres}" | awk 'NR>1 { printf("%.2f", $7/1024); }')

  local mem_used_percent=$((100*"${MEMORY_USED}"/"${MEMORY_AVAILABLE}"))

  echo "${INFO} cpu ${cpu}%"
  echo "${INFO} mem ${mem_used_percent}% (${MEMORY_USED} MB from ${MEMORY_AVAILABLE})"
  echo "${INFO} srv ${mem1}% (${mem2} MB)"
  echo "${INFO} jvm ${jvm1}% (${jvm2} MB from ${jvm3} MB)"
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
  local port=$(grep "RCONPort=" "${ZOMBOID_FILE_CONFIG_INI}"); port=${port//RCONPort=/}; port=${port// /}
  local password=$(grep "RCONPassword=" "${ZOMBOID_FILE_CONFIG_INI}"); password=${password//RCONPassword=/}; password=${password// /}

  ${UTIL_RCON_FILE} -a "${host}:${port}" -p "${password}" -c "${command}"
}

# kickusers kicks all players from the server.
function kickusers() {
  local players=$(rconcmd "players" | grep ^"-")

  if [ "${players}" ]; then
    IFS=$'\n'
    declare -a a
    a=(${players})
    for line in "${a[@]}"
    do
      local username="${line:1}"
      screencmd "kickuser \"${username}\""
    done
  fi

  # TODO: Add success or fail message.
}

# start starts the server in a screen window.
# An error message will be displayed if server has been started earlier.
function start() {
  echo "${OK} starting the server..."

  local pid_screen=$(ps aux | grep -v grep | grep -i "screen -U -mdS ${SCREEN_ZOMBOID} " | awk '{print $2}')
  if [ -n "${pid_screen}" ]; then
    echo "${INFO} server already started"
    return 0
  fi

  screen -wipe > /dev/null 2>&1; sleep 1s
  env LANG=ru_RU.utf8 screen -U -mdS "${SCREEN_ZOMBOID}" "${SERVER_DIR}/start-server.sh" -servername "${SERVER_NAME}"

  if [ ! $? -eq 0  ]; then
    echoerr "server is not started"
    return 1
  fi

  if [ "$1" == "first" ] && [ -n "${FIRST_RUN_ADMIN_PASSWORD}" ]; then
    sleep 1s && screencmd "${FIRST_RUN_ADMIN_PASSWORD}"
    sleep 1s && screencmd "${FIRST_RUN_ADMIN_PASSWORD}"
  fi
}

# stop stops the server.
function stop() {
  echo "${INFO} stopping the server..."

  local pid_screen=$(ps aux | grep -v grep | grep -i "screen -U -mdS ${SCREEN_ZOMBOID} " | awk '{print $2}')
  if [ -z "${pid_screen}" ]; then
    echoerr "server already stopped"
    return 0
  fi

  # kickusers is used for fix a game bug.
  # When `quit` game command is executed, there is no log record the fact
  # that the players was exit the game. If you make a forced kick from the
  # server, then the log entry appears correctly.
  # TODO: This is not entirely true. Kick of the players occurs, but the log entry does not always appear.
  kickusers

  sleep 1s

  if ! screencmd 'quit'; then
    echoerr "server is not stopped correctly"
  fi

  # If after a regular shutdown server remains running, we must forcibly stop it.
  sleep 10s

  pid_screen=$(ps aux | grep -v grep | grep -i "screen -U -mdS ${SCREEN_ZOMBOID} " | awk '{print $2}')
  if [ -n "${pid_screen}" ]; then
    echo "${INFO} kill screen process ${pid_screen}"
    kill "${pid_screen}" > /dev/null 2>&1; sleep 1s
  fi

  echo "${OK} server is stopped"

  # After a stopping the server invokes the function of cleaning garbage that
  # the game generates during its operation.
  delete_old_chunks
  delete_old_logs
  delete_old_java_stack_traces "${CLEAR_STACK_TRACE_DAY}"
}

# restart stops the server and starts it after 10 seconds.
function restart() {
  echo "${INFO} restarting the server..."

  stop
  sleep 10s
  start
}

# shutdown_wrapper triggers informational messages for players to alert them of
# impending server shutdown. After 5 minutes, it calls the stop or restart
# function.
function shutdown_wrapper() {
  local pid_screen=$(ps aux | grep -v grep | grep -i "screen -U -mdS ${SCREEN_ZOMBOID} " | awk '{print $2}')
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
      let t=t-1
    done
  }

  case "$1" in
    stop)
      ticker "Stopping the server in" "$2"
      stop
      ;;
    restart)
      ticker "Restarting the server in" "$2"
      restart
      ;;
    *)
      echoerr "wrong shutdown command: $1"
      return 1
      ;;
  esac
}

# delete_zombies deletes all zpop_*_*.bin files from Zomboid/Saves directory.
# These files are responsible for placing zombies on the world.
# It is recommended to use with a turned off server. When used on a running
# server, it can create more problems than it solves.
# But it can help the game restart the threads responsible for the zombies,
# if they freeze.
function delete_zombies() {
  local count=$(find "${ZOMBOID_DIR_MAP}" -name "zpop_*_*.bin" | wc -l)
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

  local count=$(find "${ZOMBOID_DIR_MAP}" -name "map_*_*.bin" -mtime +${days} | wc -l)
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
  local top_x="${point_top[0]}";
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
  if [ ! -f ${UTIL_RANGE_FILE} ]; then
     echoerr "util range.sh is not found"
     return 1
  fi

  local from="$1"
  local to="$2"
  local rectangle=($(get_rectangle "${from}" "${to}"))

  local top_x=$(echo "${rectangle[0]}" |bc)
  local top_y=$(echo "${rectangle[1]}" |bc)
  local bot_x=$(echo "${rectangle[2]}" |bc)
  local bot_y=$(echo "${rectangle[3]}" |bc)

  if [ "${top_x}" -ge "${bot_x}" ] || [ "${top_y}" -ge "${bot_y}" ]; then
     echoerr "invalid points"
     return 1
  fi

  # local s1=$(${UTIL_RANGE_FILE} 12568 13343)
  # local s2=$(${UTIL_RANGE_FILE} 12568 13343)

  local range_x=$(${UTIL_RANGE_FILE} ${top_x} ${bot_x})
  local range_y=$(${UTIL_RANGE_FILE} ${top_y} ${bot_y})

  echo "${range_x},${range_y}"
}

# backup copies server files to backup/server directory.
# TODO: Refactor backup function.
# After successful copying, check for old backups and delete them.
# TODO: Move removing old backups into a separate function.
function backup() {
  local backup_path="${DIR_BACKUPS}/server"

  mkdir -p ${backup_path} #> /dev/null 2>&1
  if [ ! $? -eq 0 ]; then
    echoerr "can not create directory ${backup_path} to backup"
    return 1
  fi

  if [ -n "${ZOMBOID_DIR}" ]; then
    echo "${INFO} backup zomboid files..."

    local name="zomboid_${NOW}.tar.gz"
    tar -czf "${backup_path}/${name}" -P --warning=no-file-changed ${ZOMBOID_DIR}
    if [ $? -eq 0 ]; then
      echo "${OK} backup ${name} created successful"

      # Delete old backups.
      if [ ! "${CLEAR_BACKUPS_DAY}" -eq "0" ]; then
        find "${DIR_BACKUPS}/server" -name "*" -mtime +${CLEAR_BACKUPS_DAY} -delete
      fi
    else
      echoerr "backup not created"
      return 1
    fi
  fi
}

# log_search looks for string $1 in log files. Chat logs excluded from search.
# Using the optional parameter $ 2, you can specify the name of the log file to
# search.
#
# Example: log_search outdead
# Example: log_search outdead user
function log_search() {
  if [ -z "$1" ]; then
     echoerr "search param is not set"
     return 1
  fi

  local filename="$2"
  if [ -n "${filename}" ]; then
    grep --include=*_"${filename}".txt -rIah "$1" "${ZOMBOID_DIR_LOGS}" | sort -b -k1.7,1.8 -k1.4,1.6 -k1.1,1.2
  else
    grep --exclude=*_chat.txt -rIah "$1" "${ZOMBOID_DIR_LOGS}" | sort -b -k1.7,1.8 -k1.4,1.6 -k1.1,1.2
  fi
}

# fn_sqlite fulfills query $1 to the Project Zomboid database and displays its
# result.
#
# Example: fn_sqlite 'select * from whitelist limit 1'
function fn_sqlite() {
  local query="$1"
  if [ -z "${query}" ]; then
     echoerr "query param is not set"
     return 1
  fi

  sqlite3 "${ZOMBOID_FILE_DB}" "${query}"
}

# fix_options changes game language to EN.
function fix_options() {
  sed -i -r "s/language=.*/language=EN/g" "${ZOMBOID_DIR}/options.ini"
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
    info)
      stats
      ;;
    start)
      start "$2"
      ;;
    stop)
      shutdown_wrapper "stop" "$2"
      ;;
    restart)
      shutdown_wrapper "restart" "$2"
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
    backup)
      backup
      ;;
    log)
      log_search "$2" "$3"
      ;;
    sql)
      fn_sqlite "$2"
      ;;
    range)
      range "$2" "$3"
      ;;
    fix)
      fix_options
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
  echo "........ info"
  echo "........ start [first]"
  echo "........ stop [now]"
  echo "........ restart [now]"
  echo "........ kickusers"
  echo "........ rcon 'command'"
  echo "........ screen 'command'"
  echo "........ log_clear [int]"
  echo "........ map_clear [int]"
  echo "........ map_copy top bottom [name]"
  echo "........ map_copyto top bottom top_new bottom_new [name]"
  echo "........ map_regen {top} {bottom}"
  echo "........ range {top} {bottom}"
  echo "........ zombie_delete"
  echo "........ backup"
  echo "........ logpvp"
  echo "........ log {search} [type]"
  echo "........ sql {query}"
  echo "........ fix"
  printf "[  >>  ] " & read CMD
fi

if [ -n "$CMD" ]; then
  IFS=' ' read -ra args <<< "${CMD}"
  main "${args[@]}"
else
  main "$@"
fi
