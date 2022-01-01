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

eval_echo() {
    to_run=$1
    echo "[94m"
    echo $to_run
    echo "[0m"

    eval $to_run
}

if [ "x$CONFIG" = "x" ]; then
    eval_echo ". config.sh" ;
fi

eval_echo "docker-compose down --remove-orphans"

echo ""

if [ "x$PGADMIN" = "xtrue" ]; then
    echo "[93mWARNING: PGAdmin will start on port $PGADMIN_PORT[0m"
    pgadmin="-f pgadmin.yml"
fi

if [ "x$CLIENT_RUNNER" = "xtrue" ]; then
    echo "[93mClient runner will start[0m"
    client_runner="-f client-runner.yml"
fi

if [ "x$BALANCER" = "xtrue" ]; then
    echo "[93mBalancer will start[0m"
    balancer="-f balancer.yml"
fi

if [ "x$CODENJOY" = "xtrue" ]; then
    echo "[93mCodenjoy will start[0m"
    codenjoy="-f codenjoy.yml"
fi

if [ "x$WORDPRESS" = "xtrue" ]; then
    echo "[93mWordpress will start[0m"
    wordpress="-f wordpress.yml"
fi

if [[ "$SPRING_PROFILES" =~ "postgres" ]]; then
    eval_echo "docker-compose -f docker-compose.yml $client_runner $balancer $codenjoy $wordpress $pgadmin up -d codenjoy_db"
    sleep 10
fi

eval_echo "docker-compose -f docker-compose.yml $client_runner $balancer $codenjoy $wordpress $pgadmin up -d"

eval_echo "date"
eval_echo "docker exec -it codenjoy-database date"
eval_echo "docker exec -it codenjoy-contest date"
eval_echo "docker exec -it codenjoy-client-runner date"
eval_echo "docker exec -it codenjoy-balancer date"
eval_echo "docker exec -it nginx date"
eval_echo "docker exec -it codenjoy-balancer-frontend date"
eval_echo "docker exec -it wordpress date"
eval_echo "docker exec -it wordpress-database date"

