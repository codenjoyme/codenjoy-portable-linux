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

echo "[92m========================================================================================================================"
echo "========================================================= START ========================================================"
echo "========================================================================================================================[0m"

eval_echo() {
    to_run=$1
    echo "[94m"
    echo $to_run
    echo "[0m"

    eval $to_run
}

eval_echo ". dir.sh"
eval_echo ". config.sh"

eval_echo "bash init-structure.sh"

# TODO continue with db backup
# eval_echo "cd $DIR/materials && bash backup.sh"

eval_echo "cd $DIR/logs && bash get-docker-compose-logs.sh"

eval_echo "cd $DIR/applications && . build.sh"

eval_echo "docker container rm $(docker ps -a | grep -v 'CONTAINER' | cut -d ' ' -f1) --force"
eval_echo "docker network prune --force"
eval_echo "docker rmi apofig/codenjoy-contest:${CODENJOY_VERSION} --force"
eval_echo "docker rmi apofig/codenjoy-client-runner:${CODENJOY_VERSION} --force"
eval_echo "docker rmi apofig/codenjoy-balancer:${CODENJOY_VERSION} --force"
eval_echo "docker rmi apofig/codenjoy-balancer-frontend:${CODENJOY_VERSION} --force"

echo "[92m========================================================================================================================"
echo "================================================ Docker compose starting ==============================================="
echo "========================================================================================================================[0m"

eval_echo "cd $DIR && docker-compose build --no-cache"
eval_echo "cd $DIR && bash up.sh"

echo "[92m========================================================================================================================"
echo "========================================================= DONE ========================================================="
echo "========================================================================================================================[0m"

eval_echo "cd $DIR/applications && bash check-revision.sh"