#!/bin/bash

# Logsfinder plugin for Project Zomboid Linux Server Manager.
#
# Copyright (c) 2023 Pavel Korotkiy (outdead).
# Use of this source code is governed by the MIT license.

# find_steams prints user's SteamIDs.
function find_steams() {
  local username="$1"
  if [ -z "${username}" ]; then
     echoerr "username is not set"; return 1
  fi

  local result; result="$(log_search "\"${username}\"" user | grep "fully connected")"

  local date="$2"
  if [ -n "${date}" ]; then
    result="$(echo "${result}" | grep -E "${date}")"
  fi

  echo "${result}" | grep -oE "[0-9]{17}" | sort -u
}

# find_ips prints user's IPs.
function find_ips() {
  local username="$1"
  if [ -z "${username}" ]; then
     echoerr "username is not set"; return 1
  fi

  local result; result="$(log_search "\"${username}\"" DebugLog-server | grep "ConnectionManager")"

  local date="$2"
  if [ -n "${date}" ]; then
    result="$(echo "${result}" | grep -E "${date}")"
  fi

  echo "${result}" | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | sort -u
}

# find_all_users_by_ip prints all usernames, connected with ip.
function find_all_users_by_ip() {
  local ip="$1"
  if [ -z "${ip}" ]; then
     echoerr "ip is not set"; return 1
  fi

  log_search "username=\"" DebugLog-server | grep "${ip}" | grep -Eo "username=\".*\" " | sed 's/username=\"//g' | sed 's/\" //g' | grep -v "null" | sort -u
}

# find_kicks prints user's kick records from current logs.
function find_kicks() {
  local username="$1"
  if [ -z "${username}" ]; then
     echoerr "username is not set"; return 1
  fi

  local date="$2"
  if [ -n "${date}" ]; then
    clog_search "${date}" DebugLog-server | grep -Eo "\[[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+.[0-9]+\] > ConnectionManager: \[kick\] .*" | grep -E "username=\"${username}\""
  else
    clog_search "username=\"${username}\"" DebugLog-server | grep -Eo "\[[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+.[0-9]+\] > ConnectionManager: \[kick\] .*"
  fi
}

# find_all_kicks prints user's kick records from all logs.
function find_all_kicks() {
  local username="$1"
  if [ -z "${username}" ]; then
     echoerr "username is not set"; return 1
  fi

  local date="$2"
  if [ -n "${date}" ]; then
    log_search "${date}" DebugLog-server | grep -Eo "\[[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+.[0-9]+\] > ConnectionManager: \[kick\] .*" | grep -E "username=\"${username}\""
  else
    log_search "username=\"${username}\"" DebugLog-server | grep -Eo "\[[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+.[0-9]+\] > ConnectionManager: \[kick\] .*"
  fi
}

# kicks_count prints kicks count in last game session.
function kicks_count() {
  find_kicks "$1" "$2" | wc -l
}

read -r -d '' PLUGINS_COMMANDS_HELP << EOM
  ${PLUGINS_COMMANDS_HELP}
  steams [args]           Looks for logs files and searches user's SteamIDs.
  ips [args]              Looks for logs files and searches user's IPs.
  ipusers ip              Prints all usernames, connected with ip.
  kicks username [date]   Looks for logs files and searches user's kick records.
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
      # TODO: Add help, add args.
      find_all_users_by_ip "$2";;
    kicks)
      # TODO: Add help, refactor args.
      case "$2" in
        --help)
          ;;
        -a|--all)
          find_all_kicks "$3" "$4";;
        -c|--count)
          kicks_count "$3" "$4";;
        *)
          find_kicks "$2" "$3";;
      esac;;
  esac
}
