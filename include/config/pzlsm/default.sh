#!/usr/bin/env bash

# NOW is the current date and time in default format Y%m%d_%H%M%S.
NOW=$(date "+%Y%m%d_%H%M%S")

SCREEN_ZOMBOID="zomboid"

# UTIL_RANGE_VERSION contains version of range builder.
UTIL_RANGE_VERSION="1.0.0"

# UTIL_RCON_VERSION contains version of rcon client.
UTIL_RCON_VERSION="0.4.0"

# SERVER_MEMORY_LIMIT contains memory Limit for JVM in MB.
SERVER_MEMORY_LIMIT=2500

# SERVER_NAME contains name of Project Zomboid server.
SERVER_NAME="servertest"

# SERVER_DIR indicates the directory where the game Project Zomboid.
# is installed.
SERVER_DIR="${HOME}/pz/content"

# ZOMBOID_DIR indicates the directory with server game data files.
ZOMBOID_DIR="${SERVER_DIR}/Zomboid"

# DIR_BACKUPS path to backups.
DIR_BACKUPS="${BASEDIR}/backups"

# CLEAR_MAP_DAY contains the number of days after which map chunks will
# be deleted if no one has visited them. Set to 0 to turn off.
CLEAR_MAP_DAY=21

# CLEAR_LOGS_DAY contains the number of days after which old game logs will
# be deleted. Set to 0 to turn off.
CLEAR_LOGS_DAY=1000

# CLEAR_STACK_TRACE_DAY contains the number of days after which old game
# hs_err_pid (java stack traces) files will be deleted. Set to 0 to turn off.
CLEAR_STACK_TRACE_DAY=1000

# CLEAR_BACKUPS_DAY contains the number of days after which old backups
# will be deleted. Set to 0 to turn off.
CLEAR_BACKUPS_DAY=100

# CLEAR_TIME_MACHINE_DAY contains the number of days after which old
# time machine backups will be deleted. Set to 0 to turn off.
CLEAR_TIME_MACHINE_DAY=5

# BACKUP_ON_STOP contains switcher to make backup on every server stop.
BACKUP_ON_STOP="true"

# FIRST_RUN_ADMIN_PASSWORD contains password for user admin which be created
# on first server run.
FIRST_RUN_ADMIN_PASSWORD="changeme"

# GITHUB_CONFIG_REPO contains link to github repo with pz config files.
# Leave it blank if you don't plan to use this.
GITHUB_CONFIG_REPO=""

# GITHUB_ACCESS_TOKEN contains access token for download server configs from GitHub.
# Leave it blank if you don't plan to use this.
GITHUB_ACCESS_TOKEN=""
