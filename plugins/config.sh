#!/bin/bash

# Config plugin for Project Zomboid Linux Server Manager.
#
# Copyright (c) 2022 Pavel Korotkiy (outdead).
# Use of this source code is governed by the MIT license.

# config_pull downloads Project Zomboid config files from github repo.
function config_pull() {
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

# Display description in plugins list.
read -r -d '' PLUGINS_COMMANDS_HELP << EOM
  ${PLUGINS_COMMANDS_HELP}
  config                  Contains commands for manipulating server config.
EOM

# print_help_ prints help about stats command.
function print_help_config() {
  echo "COMMAND NAME:"
  echo "  config"
  echo
  echo "DESCRIPTION:"
  echo "  Contains commands for manipulating server config."
  echo
  echo "USAGE:"
  echo "  $0 config subcommand [arguments...] [options...]"
  echo
  echo "SUBCOMMANDS:"
  echo "  pull        Downloads Project Zomboid config files from github repo."
  echo "              Be careful - old PZ config files will be rewritten."
  echo "  EXAMPLE:"
  echo "    $0 config pull"
}

# load contains a proxy for entering permissible functions.
function load() {
  case "$1" in
    config)
      case "$2" in
        pull)
          config_pull;;
        --help|*)
          if [ -z "$2" ]; then
            print_help_config; return
          fi
          print_help_config;;
      esac
  esac
}
