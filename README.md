# pzlsm
Project Zomboid Linux Server Manager (pzlsm) - terminal tool for manage Project Zomboid server on Linux.  

## Installation
1. Do not work on root. Create a user and login.

       adduser pz
       su - pz

2. Create directory for you server.
   
       mkdir pz1 && cd pz1

3. Download the `server.sh` file from the [latest releases](https://github.com/openzomboid/pzctl/releases/latest) and put it to your server.
   
       wget -O server.sh https://raw.githubusercontent.com/openzomboid/pzlsm/master/server.sh && chmod +x server.sh

4. Install dependencies and PZ server.
   
       ./server.sh install

## Usage
```text
USAGE:
  ./server.sh [global options] command [arguments...] [options]

GLOBAL OPTIONS:
  --variables, --vars     Print variables.
  --version               Print the version.
  --help                  Show help.

COMMANDS:
  install [args]          Installs Project Zomboid dedicated server.
  update                  Updates Project Zomboid dedicated server.
  start [args]            Starts the server in a screen window. An error message will
                          be displayed if server has been started earlier.
  stop [args]             Stops the server. Triggers informational messages for players
                          to alert them of impending server shutdown.
  restart [args]          Restarts the server. Triggers informational messages for players
                          to alert them of impending server shutdown.
  autorestart             Restarts server if it stuck an backups last logs.
  console                 Allows access the output of the game server console.
  cmd [args]              Executes the 1 argument as a command on the game server.
  kickusers               Kicks all players from the server.
  delfile [args]          Deletes selected Project Zomboid files.
  map [args]              Manipulates with map chunk files.
  range [args]            Takes the coordinates of the upper right and lower left points
                          and builds a rectangular area of chunks from them for generating regexp
                          rule for searching the log.
  backup [args]           Copies server files to backup directory. After successful copying, check
                          for old backups and delete them.
  log [args]              Looks for string 1 in log files. Chat logs excluded from search.
                          Using the optional parameter 2, you can specify the name of the log
                          file to search.
  sql [args]              Executes query 1 to the Project Zomboid database and displays result.
  players [args]          Manipulates with players database.
  vehicles [args]         Manipulates with vehicles database..

PLUGINS:
  web                     Contains presets to web commands.
```
