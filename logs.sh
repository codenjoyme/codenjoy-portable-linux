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

if [ "x$CONFIG" = "x" ]; then
    . config.sh ;
fi

service=$1

eval_echo() {
    to_run=$1
    echo "[94m"
    echo $to_run
    echo "[0m"

    eval $to_run
}

if [ "x$PGADMIN" = "xtrue" ]; then
    pgadmin="-f pgadmin.yml"
fi

if [ "x$BALANCER" = "xtrue" ]; then
    balancer="-f balancer.yml"
fi

if [ "x$CODENJOY" = "xtrue" ]; then
    codenjoy="-f codenjoy.yml"
fi

if [ "x$CLIENT_RUNNER" = "xtrue" ]; then
    client_runner="-f client-runner.yml"
fi

if [ "x$WORDPRESS" = "xtrue" ]; then
    wordpress="-f wordpress.yml"
fi

eval_echo "docker-compose -f docker-compose.yml $balancer $codenjoy $client_runner $wordpress $pgadmin logs $service"