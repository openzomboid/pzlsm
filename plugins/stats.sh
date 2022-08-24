#!/bin/bash

# Statistics plugin for Project Zomboid Linux Server Manager.
#
# Copyright (c) 2022 Pavel Korotkiy (outdead).
# Use of this source code is governed by the MIT license.

# stats displays information on the peak processor consumption and
# current RAM consumption.
function stats() {
  local pid_zomboid=""
  pid_zomboid=$(get_server_pid)
  if [ -z "${pid_zomboid}" ]; then
    echoerr "server is not running"; return 1
  fi

  local cpu; cpu=$(strclear "$(ps S -p "${pid_zomboid}" -o pcpu=)")

  local mem1; mem1=$(ps S -p "${pid_zomboid}" -o pmem=)
  local mem2; mem2=$(ps -ylp "${pid_zomboid}" | awk '{x += $8} END {print "" x/1024;}')

  local jvmres; jvmres=$(jstat -gc "${pid_zomboid}")

  local jvm1; jvm1=$(echo "${jvmres}" | awk 'NR>1 { printf("%.1f", $8/$7*100); }')
  local jvm2; jvm2=$(echo "${jvmres}" | awk 'NR>1 { printf("%.2f", $8/1024); }')
  local jvm3; jvm3=$(echo "${jvmres}" | awk 'NR>1 { printf("%.2f", $7/1024); }')

  local mem_used_percent=$((100*"${MEMORY_USED}"/"${MEMORY_AVAILABLE}"))

  local uptime; uptime=$(ps -p "${pid_zomboid}" -o etime | grep -v "ELAPSED" | xargs)

  echo "${INFO} cpu srv:  ${cpu}%"
  echo "${INFO} mem host: ${mem_used_percent}% (${MEMORY_USED} MB from ${MEMORY_AVAILABLE})"
  echo "${INFO} mem srv:  ${mem1}% (${mem2} MB)"
  echo "${INFO} mem jvm:  ${jvm1}% (${jvm2} MB from ${jvm3} MB)"
  echo "${INFO} uptime:   ${uptime}"
}

# stats_top prints list of top $1 processes with memory usage.
function stats_top() {
  local number="$1"
  [ -z "${number}" ] && number=10

  ps axo rss,comm,pid | awk '{ proc_list[$2]++; proc_list[$2 "," 1] += $1; } END { for (proc in proc_list) { printf("%d\t%s\n", proc_list[proc "," 1],proc); }}' | sort -n | tail -n ${number} | sort -rn | awk '{$1/=1024;printf "%.0fMB\t",$1}{print $2}'
}

read -r -d '' PLUGINS_COMMANDS_HELP << EOM
  ${PLUGINS_COMMANDS_HELP}
  stats                   Displays information on the peak processor consumption,
                          current RAM consumption and other game stats.
EOM

# print_help_ prints help about stats command.
function print_help_stats() {
  echo "COMMAND NAME:"
  echo "  stats"
  echo
  echo "DESCRIPTION:"
  echo "  Contains presets to OS statistics."
  echo "  Keep sub commands empty to use default action."
  echo
  echo "USAGE:"
  echo "  $0 stats subcommand [arguments...] [options...]"
  echo
  echo "SUBCOMMANDS:"
  echo "  info     Displays information on the peak processor consumption and"
  echo "           current RAM consumption (Default command)."
  echo "  EXAMPLE:"
  echo "    $0 stats info"
  echo "    $0 stats"
  echo
  echo "  top      Prints list of top processes with memory usage."
  echo "  OPTIONS:"
  echo "    --number|-n     Number of lines (default=10)."
  echo "  EXAMPLE:"
  echo "    $0 stats top -n 10"
}

# load contains a proxy for entering permissible functions.
function load() {
  case "$1" in
    stats)
      case "$2" in
        info)
          stats;;
        top)
          local number=10

          while [[ -n "$1" ]]; do
            case "$1" in
              --number|-n) param="$2"
                number="$param"
                shift;;
            esac

            shift
          done

          stats_top "${number}";;
        --help|*)
          if [ -z "$2" ]; then
            stats; return
          fi
          print_help_stats;;
      esac
  esac
}
