# pzlsm
Terminal tool for manage Project Zomboid server on Linux (pzlsm).  

## Installation
1. Download the server.sh file from the [latest releases](https://github.com/openzomboid/pzctl/releases/latest)
2. Put it to your server
3. Configure config in `.env` or in `config/pzlsm.cfg`
4. Execute
   
       sudo ./server.sh prepare
       ./server.sh install
       ./server.sh fix
       ./server.sh start first

## Usage
```text
USAGE:
  ./server.sh [global options] command [arguments...] [options]

GLOBAL OPTIONS:
  --variables, --vars     print variables
  --version               print the version
  --help                  show help

COMMANDS:
  dependencies            installs the necessary dependencies to the server.
                          You must have sudo privileges to call function dependencies.
  directories             creates directories for pzlsm script.
  utils                   downloads vendor utils from repositories and puts them
                          to the utils directory.
  prepare                 calls dependencies, directories and utils functions.
  install [args...]       installs Project Zomboid dedicated server.
  fix                     changes game language to EN and sets Project Zomboid args.
  sync                    downloads Project Zomboid config files from github repo.
  info                    displays information on the peak processor consumption,
                          current RAM consumption and other game stats.
  start [args...]         starts the server in a screen window. An error message will
                          be displayed if server has been started earlier
  stop [args...]          stops the server. Triggers informational messages for players
                          to alert them of impending server shutdown.
  restart [args...]       restarts the server. Triggers informational messages for players
                          to alert them of impending server shutdown.
  restart_if_stuck        restarts server if it stuck an backups last logs.
  screen [args...]        calls the 1 argument as a command on the game using screen util.
  rcon [args...]          calls the 1 argument as a command on the game using rcon util.
  kickusers               kicks all players from the server.
  delete_manifest         deletes appworkshop_108600.acf file. It need to
                          update mods correctly.
  delete_zombies          deletes all zpop_*_*.bin files from Zomboid/Saves directory.
                          These files are responsible for placing zombies on the world.
                          It is recommended to use with a turned off server. When used on
                          a running server, it can create more problems than it solves.
  map_regen [args...]     takes the coordinates of the upper right and lower left points
                          and builds a rectangular area of chunks from them and deletes them.
  map_copy [args...]      takes the coordinates of the upper right and lower left points
                          and builds a rectangular area of chunks from them and copies them to
                          backups/copy directory. With an additional argument, you can specify
                          a name for the catalog of copied chunks. If you don't specify a name,
                          then it will generated based on the coordinates
  map_copyto [args...]    takes the coordinates of the upper right and lower left points
                          and builds a rectangular area of chunks from them and copies them
                          to backups/copy directory and rename to new coordinates. With an
                          additional argument, you can specify a name for the catalog of copied
                          chunks. If you don't specify a name, then it will generated based on
                          the coordinates.
  range [args...]         takes the coordinates of the upper right and lower left points
                          and builds a rectangular area of chunks from them for generating regexp
                          rule for searching the log.
  backup [args...]        copies server files to backup directory. After successful copying, check
                          for old backups and delete them.
  log [args...]           looks for string 1 in log files. Chat logs excluded from search.
                          Using the optional parameter 2, you can specify the name of the log
                          file to search.
  log [args...]           looks for string 1 in in current log files. Chat logs excluded from search.
                          Using the optional parameter 2, you can specify the name of the log
                          file to search.
  sql [args...]           executes query 1 to the Project Zomboid database and displays result
  restore_players [args...]  replaces players.db database from backup.
```
