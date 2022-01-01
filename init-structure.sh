#!/usr/bin/env bash

###
# #%L
# Codenjoy - it's a dojo-like platform from developers to developers.
# %%
# Copyright (C) 2012 - 2022 Codenjoy
# %%
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program.  If not, see
# <http://www.gnu.org/licenses/gpl-3.0.html>.
# #L%
###

if [ "$EUID" -ne 0 ]
  then echo "[91mPlease run as root[0m"
  exit
fi

bash setup-docker.sh

echo "[92m========================================================================================================================"
echo "==================================================== Init structure ===================================================="
echo "========================================================================================================================[0m"

if [ "x$BASIC_AUTH_LOGIN" = "x" ]; then
    . config.sh ;
fi

if [ "x$BASIC_AUTH_PASSWORD" = "x" ]; then
    . config.sh ;
fi

if [ "x$TIMEZONE" = "x" ]; then
    . config.sh ;
fi

if [ "x$SPRING_PROFILES" = "x" ]; then
    . config.sh ;
fi

eval_echo() {
    to_run=$1
    echo "[94m"
    echo $to_run
    echo "[0m"

    eval $to_run
}

eval_echo "unlink /etc/localtime & ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime"
sudo dpkg-reconfigure -f noninteractive tzdata

# for nginx
generate_htpasswd() {
    rm ./config/nginx/.htpasswd
    touch ./config/nginx/.htpasswd
    sudo sh -c "echo -n '$BASIC_AUTH_LOGIN:' >> ./config/nginx/.htpasswd"
    sudo sh -c "openssl passwd -apr1 $BASIC_AUTH_PASSWORD >> ./config/nginx/.htpasswd"
    cat ./config/nginx/.htpasswd
}
eval_echo "generate_htpasswd"

eval_echo "chown root:root ./ssl-cert/*"
ls -la ./ssl-cert

eval_echo "chown root:root ./config/nginx/*"
ls -la ./config/nginx

# maven
eval_echo "mkdir -p ./materials/maven"
eval_echo "chown root:root ./materials/maven"
ls -la ./materials/maven

# database
eval_echo "mkdir -p ./materials/codenjoy/database"
eval_echo "chown root:root ./materials/codenjoy/database"
ls -la ./materials/codenjoy/database

# client runner
eval_echo "mkdir -p ./materials/client-runner/sources"
eval_echo "chown root:root ./materials/client-runner/sources"
ls -la ./materials/client-runner/sources

# for codenjoy_balancer / codenjoy_contest
eval_echo "mkdir -p ./config/codenjoy"
eval_echo "chown root:root ./config/codenjoy"
ls -la ./config/codenjoy

# logs
eval_echo "mkdir -p ./logs/codenjoy"
eval_echo "mkdir -p ./logs/client-runner"
# TODO uncomment when fix
# eval_echo "touch ./logs/codenjoy/codenjoy-balancer.log"
# eval_echo "touch ./logs/codenjoy/codenjoy-contest.log"
# eval_echo "chown root:root ./logs/codenjoy/codenjoy-balancer.log"
# eval_echo "chown root:root ./logs/codenjoy/codenjoy-contest.log"
ls -la ./logs/codenjoy
