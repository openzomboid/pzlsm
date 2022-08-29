#!/bin/bash

# Statistics plugin for Project Zomboid Linux Server Manager.
#
# Copyright (c) 2022 Pavel Korotkiy (outdead).
# Use of this source code is governed by the MIT license.

# web_install installs nginx, certbot.
function web_install() {
  apt-get update && apt-get install -y nginx

  if [ ! -f "/etc/nginx/.htpasswd" ] ; then
    touch "/etc/nginx/.htpasswd"
  fi

  mkdir -p /etc/nginx/includes

  bash -c "cat <<EOF > /etc/nginx/includes/${BASENAME}
location /${BASENAME} {
        auth_basic \"Restricted Content\";
        auth_basic_user_file /etc/nginx/.htpasswd;

        charset utf-8;
        autoindex on;
        autoindex_localtime on;
        disable_symlinks off;
        alias ${DIR_PUBLIC};
}
EOF"

  ufw allow 'Nginx HTTP'

  if [ "${ENABLE_MUNIN}" == "true" ]; then
    apt install -y munin munin-node munin-plugins-extra spawn-fcgi

    bash -c 'cat <<EOF > /etc/systemd/system/munin-fcgi-graph.service
[Unit]
Description=Munin Graph

[Service]
Type=forking
PIDFile=/run/munin/fcgi-graph.pid
ExecStartPre=/bin/chgrp www-data /run/munin
ExecStart=/usr/bin/spawn-fcgi -s /run/munin/fcgi-graph.sock -U www-data -u www-data -g www-data /usr/lib/munin/cgi/munin-cgi-graph -P /run/munin/fcgi-graph.pid

[Install]
WantedBy=multi-user.target
EOF'

    bash -c 'cat <<EOF > /etc/systemd/system/munin-fcgi-graph.service
[Unit]
Description=Munin Graph

[Service]
Type=forking
PIDFile=/run/munin/fcgi-graph.pid
ExecStartPre=/bin/chgrp www-data /run/munin
ExecStart=/usr/bin/spawn-fcgi -s /run/munin/fcgi-graph.sock -U www-data -u www-data -g www-data /usr/lib/munin/cgi/munin-cgi-graph -P /run/munin/fcgi-graph.pid

[Install]
WantedBy=multi-user.target
EOF'

    bash -c 'cat <<EOF > /etc/systemd/system/munin-fcgi-html.service
[Unit]
Description=Munin FastCGI HTML

[Service]
Type=forking
PIDFile=/run/munin/fcgi-html.pid
ExecStartPre=/bin/chgrp www-data /run/munin
ExecStart=/usr/bin/spawn-fcgi -s /run/munin/fcgi-html.sock -U www-data -u www-data -g munin /usr/lib/munin/cgi/munin-cgi-html -P /run/munin/fcgi-html.pid

[Install]
WantedBy=multi-user.target
EOF'

    systemctl daemon-reload
    systemctl enable munin-fcgi-graph.service
    systemctl enable munin-fcgi-html.service
    systemctl start munin-fcgi-graph.service
    systemctl start munin-fcgi-html.service

    perl -pi -e 's/#graph_strategy cron/graph_strategy cgi/' /etc/munin/munin.conf
    perl -pi -e 's/#html_strategy cron/html_strategy cgi/' /etc/munin/munin.conf

    perl -pi -e "s/localhost.localdomain/${HOSTNAME}/" /etc/munin/munin.conf
    perl -pi -e "s/#host_name localhost.localdomain/host_name ${HOSTNAME}/" /etc/munin/munin-node.conf

    chgrp www-data /var/log/munin
    chgrp munin /var/log/munin/munin-cgi-*

    bash -c "cat <<'EOF' > /etc/nginx/includes/munin
location ^~ /munin-cgi/munin-cgi-graph/ {
        access_log off;
        fastcgi_split_path_info ^(/munin-cgi/munin-cgi-graph)(.*);
        fastcgi_param PATH_INFO \$fastcgi_path_info;
        fastcgi_pass unix:/run/munin/fcgi-graph.sock;
        include fastcgi_params;
}

location /munin/static/ {
        alias /etc/munin/static/;
}

location /munin/ {
        fastcgi_split_path_info ^(/munin)(.*);
        fastcgi_param PATH_INFO \$fastcgi_path_info;
        fastcgi_pass unix:/run/munin/fcgi-html.sock;
        include fastcgi_params;
}
EOF"

    wget -P /etc/munin/plugins/ https://raw.githubusercontent.com/apcro/munin-plugins/master/cpu-per-core/cpu-per-core
    chmod 0777 /etc/munin/plugins/cpu-per-core
    chmod u+x /etc/munin/plugins/cpu-per-core

    apt install smartmontools

    ln -s /usr/share/munin/plugins/smart_ /etc/munin/plugins/smart_sda
    #ln -s /usr/share/munin/plugins/smart_ /etc/munin/plugins/smart_sdb
    munin-run smart_sda

    service munin-node restart
    service nginx restart
  fi
}

# web_enable configures web.
function web_enable() {
  local domain="$1"
  local web_username="$2"
  local web_password="$3"

  if [ ! -f "/etc/nginx/.htpasswd" ] ; then
    touch "/etc/nginx/.htpasswd"
  fi

  if [ "$(wc -l < /etc/nginx/.htpasswd)" == "0" ]; then
    [ -z "${web_username}" ] && { echoerr "username is not set"; return 1; }
    [ -z "${web_password}" ] && { echoerr "password is not set"; return 1; }
  fi

  [ -n "${web_username}" ] && [ -z "${web_password}" ] && { echoerr "password is not set"; return 1; }

  if [ -n "${web_username}" ] && [ "$(grep -E -c "^${web_username}:" /etc/nginx/.htpasswd)" -eq 0 ]; then
    sh -c "echo -n '${web_username}:' >> /etc/nginx/.htpasswd"
    sh -c "openssl passwd -apr1 ${web_password} >> /etc/nginx/.htpasswd"
  fi

  if [ -z "${domain}" ]; then
    # Create Nginx location.
    if [ "$(grep -c "include includes/${BASENAME};" /etc/nginx/sites-available/default)" == "0" ]; then
      local _search="server_name _;"
      local _replace="${_search}\n\n        include includes/${BASENAME};"
      sed -i -r "s|${_search}|${_replace}|g" /etc/nginx/sites-available/default
    fi

    if [ "${ENABLE_MUNIN}" == "true" ] && [ "$(grep -c "include includes/munin;" /etc/nginx/sites-available/default)" == "0" ]; then
      local _search="include includes/${BASENAME};"
      local _replace="${_search}\n\n        include includes/munin;"
      sed -i -r "s|${_search}|${_replace}|g" /etc/nginx/sites-available/default
    fi

    echo "${INFO} web for ${BASENAME} created without domain"
  else
    bash -c "cat <<EOF > /etc/nginx/sites-available/${domain}
server {
        server_name ${domain} www.${domain};

        auth_basic \"Restricted Content\";
        auth_basic_user_file /etc/nginx/.htpasswd;

        include includes/${BASENAME};
}
EOF"

    if [ "${ENABLE_MUNIN}" == "true" ] && [ "$(grep -c "include includes/munin;" "/etc/nginx/sites-available/${domain}")" == "0" ]; then
      local _search="include includes/${BASENAME};"
      local _replace="${_search}\n\n        include includes/munin;"
      sed -i -r "s|${_search}|${_replace}|g" "/etc/nginx/sites-available/${domain}"
    fi

    ln -s "/etc/nginx/sites-available/${domain}" /etc/nginx/sites-enabled/

    echo "${INFO} web for ${BASENAME} created with domain ${domain}"
  fi

  systemctl restart nginx
}

# web_disable disables web.
function web_disable() {
  local domain="$1"

  if [ -z "${domain}" ]; then
    grep "include includes/${BASENAME};" /etc/nginx/sites-available/default >/dev/null
    if [ $? -eq 0 ]; then
      local _search="        include includes/${BASENAME};"
      sed -i "s|${_search}||g" /etc/nginx/sites-available/default
      sed -i '$!N; /^\(.*\)\n\1$/!P; D' /etc/nginx/sites-available/default
    fi

    echo "${INFO} web for ${BASENAME} disabled without domain"
  else
    rm -r "/etc/nginx/sites-enabled/${domain}"

    echo "${INFO} web for ${BASENAME} disabled with domain ${domain}"
  fi

  systemctl restart nginx
}

read -r -d '' PLUGINS_COMMANDS_HELP << EOM
  ${PLUGINS_COMMANDS_HELP}
  web                     Contains presets to web commands.
EOM

# web_help prints help about web command.
function web_help() {
  echo "COMMAND NAME:"
  echo "  web"
  echo
  echo "DESCRIPTION:"
  echo "  Contains presets to web commands."
  echo
  echo "USAGE:"
  echo "  $0 stats command [arguments...] [options...]"
  echo
  echo "COMMANDS:"
  echo "  install     Installs nginx, certbot, munin, etc."
  echo "  OPTIONS:"
  echo "  EXAMPLE:"
  echo "    $0 web install"  echo
  echo
  echo "  enable      Configures web."
  echo "  OPTIONS:"
  echo "    --domain|-d     Domain for public web (default empty)."
  echo "    --username|-u   Username for public web (default empty)."
  echo "    --password|-p   Password for public web (default empty)."
  echo "  EXAMPLE:"
  echo "    $0 web enable"
  echo
  echo "  disable     Disables web."
  echo "  OPTIONS:"
  echo "    --domain|-d     Domain for public web (default empty)."
  echo "  EXAMPLE:"
  echo "    $0 web disable"
}

# load contains a proxy for entering permissible functions.
function load() {
  case "$1" in
    web)
      case "$2" in
        install)
          web_install;;
        enable)
          local domain
          local username
          local password

          while [[ -n "$1" ]]; do
            case "$1" in
              --domain|-d) param="$2"
                domain="$param"
                shift;;
              --username|-u) param="$2"
                username="$param"
                shift;;
              --password|-p) param="$2"
                password="$param"
                shift;;
            esac

            shift
          done

          web_enable "${domain}" "${username}" "${password}";;
        disable)
          local domain

          while [[ -n "$1" ]]; do
            case "$1" in
              --domain|-d) param="$2"
                domain="$param"
                shift;;
            esac

            shift
          done

          web_disable "${domain}";;
        --help|*)
          web_help;;
      esac
  esac
}
