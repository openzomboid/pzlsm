#!/bin/bash

# Logsfind plugin for Project Zomboid Linux Server Manager.
#
# Copyright (c) 2023 Pavel Korotkiy (outdead).
# Use of this source code is governed by the MIT license.

# find_steams prints user's SteamIDs.
function find_steams() {
  local username="$1"
  if [ -z "${username}" ]; then
     echoerr "username is not set"; return 1
  fi

  if [ "${username:0:1}" == "-" ]; then
     echoerr "username is incorrect"; return 1
  fi

  local result; result="$(log_search "\"${username}\"" user | grep "fully connected")"

  local date="$2"
  if [ -n "${date}" ]; then
    result="$(echo "${result}" | grep -E "${date}")"
  fi

  result="$(echo "${result}" | grep -oE "[0-9]{17}" | sort -u)"

  echo "${result}"
}

# find_ips prints user's IPs.
function find_ips() {
  local username="$1"
  if [ -z "${username}" ]; then
     echoerr "username is not set"; return 1
  fi

  if [ "${username:0:1}" == "-" ]; then
     echoerr "username is incorrect"; return 1
  fi

  local result; result="$(log_search "\"${username}\"" DebugLog-server | grep "ConnectionManager")"

  local date="$2"
  if [ -n "${date}" ]; then
    result="$(echo "${result}" | grep -E "${date}")"
  fi

  result="$(echo "${result}" | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | sort -u)"

  echo "${result}"
}

# find_users_by_ip prints all usernames, connected with ip.
function find_users_by_ip() {
  local ip="$1"
  if [ -z "${ip}" ]; then
     echoerr "ip is not set"; return 1
  fi

  if [ "${ip:0:1}" == "-" ]; then
     echoerr "ip is incorrect"; return 1
  fi

  local result; result="$(log_search "ConnectionManager" DebugLog-server | grep "ip=${ip}")"

  local date="$2"
  if [ -n "${date}" ]; then
    result="$(echo "${result}" | grep -E "${date}")"
  fi

  result="$(echo "${result}" | grep -Eo "username=\".*\" " | sed 's/username=\"//g' | sed 's/\" //g' | grep -v "null" | sort -u)"

  echo "${result}"
}

# find_kicks prints user's kick records from current logs.
function find_kicks() {
  local username="$1"
  if [ -z "${username}" ]; then
     echoerr "username is not set"; return 1
  fi

  if [ "${username:0:1}" == "-" ]; then
     echoerr "username is incorrect"; return 1
  fi

  local result;

  local current="$3"
  if [ "${current}" == "true" ]; then
    result="$(clog_search "username=\"${username}\"" DebugLog-server)"
  else
    result="$(log_search "username=\"${username}\"" DebugLog-server)"
  fi

  local date="$2"
  if [ -n "${date}" ]; then
    result="$(echo "${result}" | grep -E "${date}")"
  fi

  result="$(echo "${result}" | grep -Eo "\[[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+.[0-9]+\] > ConnectionManager: \[kick\] .*")"

  echo "${result}"
}

read -r -d '' PLUGINS_COMMANDS_HELP << EOM
  ${PLUGINS_COMMANDS_HELP}
  steams [args]           Looks for logs files and searches user's SteamIDs.
  ips [args]              Looks for logs files and searches user's IPs.
  ipusers [args]          Prints all usernames, connected with ip.
  kicks [date]            Looks for logs files and searches user's kick records.
EOM

function find_steams_help() {
  echo "COMMAND NAME:"
  echo "  steams"
  echo
  echo "DESCRIPTION:"
  echo "  Looks for logs files and searches user's SteamIDs."
  echo
  echo "USAGE:"
  echo "  $0 steams [global options...] {username} [options...]"
  echo
  echo "GLOBAL OPTIONS:"
  echo "  --help            Prints help."
  echo
  echo "ARGUMENTS:"
  echo "  username          Username to find steams"
  echo
  echo "OPTIONS:"
  echo "  --date|-d         Set date in d-m-y format. For example 31-01-23."
  echo
  echo "EXAMPLE:"
  echo "  $0 steams outdead"
  echo "  $0 steams outdead -d 27-02-23"
}

function find_ips_help() {
  echo "COMMAND NAME:"
  echo "  ips"
  echo
  echo "DESCRIPTION:"
  echo "  Looks for logs files and searches user's IPs."
  echo
  echo "USAGE:"
  echo "  $0 ips [global options...] {username} [options...]"
  echo
  echo "GLOBAL OPTIONS:"
  echo "  --help            Prints help."
  echo
  echo "ARGUMENTS:"
  echo "  username          Username to find steams"
  echo
  echo "OPTIONS:"
  echo "  --date|-d         Set date in d-m-y format. For example 31-01-23."
  echo
  echo "EXAMPLE:"
  echo "  $0 ips outdead"
  echo "  $0 ips outdead -d 27-02-23"
}

function find_users_by_ip_help() {
  echo "COMMAND NAME:"
  echo "  ipusers"
  echo
  echo "DESCRIPTION:"
  echo "  Prints all usernames, connected with ip."
  echo
  echo "USAGE:"
  echo "  $0 ipusers [global options...] {ip} [options...]"
  echo
  echo "GLOBAL OPTIONS:"
  echo "  --help            Prints help."
  echo
  echo "ARGUMENTS:"
  echo "  ip                IP to find usernames"
  echo
  echo "OPTIONS:"
  echo "  --date|-d         Set date in d-m-y format. For example 31-01-23."
  echo
  echo "EXAMPLE:"
  echo "  $0 ipusers outdead"
  echo "  $0 ipusers outdead -d 27-02-23"
}

function find_kicks_help() {
  echo "COMMAND NAME:"
  echo "  kicks"
  echo
  echo "DESCRIPTION:"
  echo "  Looks for logs files and searches user's kick records."
  echo
  echo "USAGE:"
  echo "  $0 kicks [global options...] {username} [options...]"
  echo
  echo "GLOBAL OPTIONS:"
  echo "  --help            Prints help."
  echo
  echo "ARGUMENTS:"
  echo "  username          Username to find steams"
  echo
  echo "OPTIONS:"
  echo "  --date|-d         Set date in d-m-y format. For example 31-01-23."
  echo "  --current|-c      Search only the logs of the last game session."
  echo "  --count           Displays only the number."
  echo
  echo "EXAMPLE:"
  echo "  $0 kicks outdead -c"
  echo "  $0 kicks outdead"
  echo "  $0 kicks \".*\""
  echo "  $0 kicks \".*\" -c --count"
  echo "  $0 kicks outdead -d \"27-02-23 18:00\""
  echo "  $0 kicks outdead --count -d \"27-02-23 18:00\""
  echo "  $0 ./server.sh kicks outdead -d \"27-02-23 18:00\" -c --count"
}

# load contains a proxy for entering permissible functions.
function load() {
  case "$1" in
    steams)
      case "$2" in
        --help)
          find_steams_help;;
        *)
          local username="$2"
          local dt

          while [[ -n "$2" ]]; do
            case "$1" in
              --date|-d) param="$2"
                dt="$param"
                shift;;
            esac

            shift
          done

          find_steams "${username}" "${dt}";;
      esac;;
    ips)
      case "$2" in
        --help)
          find_ips_help;;
        *)
          local username="$2"
          local dt

          while [[ -n "$2" ]]; do
            case "$1" in
              --date|-d) param="$2"
                dt="$param"
                shift;;
            esac

            shift
          done

          find_ips "${username}" "${dt}";;
      esac;;
    ipusers)
      case "$2" in
        --help)
          find_users_by_ip_help;;
        *)
          local ip="$2"
          local dt

          while [[ -n "$2" ]]; do
            case "$1" in
              --date|-d) param="$2"
                dt="$param"
                shift;;
            esac

            shift
          done

          find_users_by_ip "${ip}" "${dt}";;
      esac;;
    kicks)
      case "$2" in
        --help)
          find_kicks_help;;
        *)
          local username="$2"
          local dt
          local current="false"
          local count="false"

          while [[ -n "$1" ]]; do
            case "$1" in
              --date|-d) param="$2"
                dt="$param"
                shift;;
              --current|-c)
                current="true";;
              --count)
                count="true";;
            esac

            shift
          done

          local result; result="$(find_kicks "${username}" "${dt}" "${current}")"

          if [ "${count}" == "true" ]; then
            echo "${result}" | wc -l
          else
            echo "${result}"
          fi;;
      esac;;
  esac
}
