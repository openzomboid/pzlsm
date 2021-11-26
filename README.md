# pzctl
Terminal tool for manage Project Zomboid server on Linux (pzlsm).  

# Config

## pzctl config

./include/config/pzlsm/default.sh
./include/config/pzlsm/local.sh

```bash
#!/usr/bin/env bash

# NOW is the current date and time in default format Y%m%d_%H%M%S.
NOW=$(date "+%Y%m%d_%H%M%S")

# UTIL_RANGE_VERSION contains version of range builder.
UTIL_RANGE_VERSION="1.0.0"

# UTIL_RCON_VERSION contains version of rcon client.
UTIL_RCON_VERSION="0.4.0"

# SERVER_MEMORY_LIMIT contains memory Limit for JVM in MB.
SERVER_MEMORY_LIMIT=1024

# SERVER_NAME contains name of Project Zomboid server.
SERVER_NAME="servertest"

# SERVER_DIR indicates the directory where the game Project Zomboid.
# is installed.
SERVER_DIR="${HOME}/pz/content"

# ZOMBOID_DIR indicates the directory with server game data files.
ZOMBOID_DIR="${SERVER_DIR}/Zomboid"

# CLEAR_MAP_DAY contains the number of days after which map chunks will
# be deleted if no one has visited them. Set to 0 to turn off.
CLEAR_MAP_DAY=21

# CLEAR_LOGS_DAY contains the number of days after which old game logs will
# be deleted. Set to 0 to turn off.
CLEAR_LOGS_DAY=1000

# CLEAR_BACKUPS_DAY contains the number of days after which old backups
# will be deleted. Set to 0 to turn off.
CLEAR_BACKUPS_DAY=100

```

## Deploy config

./include/config/deploy/default.sh
./include/config/deploy/dev.sh
