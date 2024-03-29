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
    echo "[92m"
    echo $1
    echo "[0m"

    eval $1
}

eval_echo2() {
    echo "[36m"$1"[0m"

    eval $1
}

eval_echo ". env-read.sh"

comment() {
    file=$1
    marker=$2
    flag=$3
    if [ "x$flag" = "xtrue" ]; then
        eval_echo2 "sed -i '/$marker/s/^#\+//' $file"
    else
        eval_echo2 "sed -i '/$marker/s/^#\?/#/' $file"
    fi
    cat $file | grep $marker
}

parameter() {
    file=$1
    before=$2
    value=$3
    after=$4
    if [ "x$after" = "x" ]; then
        eol="\$"
    fi
    eval_echo2 "sed -i 's,\($before\).*$after$eol,\1$value$after,' $file"
    cat $file | grep "$before"
}

# -------------------------- DOMAIN --------------------------

eval_echo "parameter ./config/nginx/domain.conf 'server_name ' $SERVER_IP ';'"

if [ "x$DOMAIN" = "xfalse" ]; then
    SERVER_DOMAIN=$SERVER_IP
fi

eval_echo "parameter ./config/nginx/domain.conf 'return 301 https\?://' $SERVER_DOMAIN '\\$'"

eval_echo "parameter ./config/nginx/conf.d/applications.conf 'server_name ' $SERVER_DOMAIN ';'"

domain() {
    file=$1
    comment $file "#D#" $DOMAIN
}

eval_echo "domain ./config/nginx/nginx.conf"

# -------------------------- OPEN PORTS --------------------------

ports() {
    file=$1
    comment $file "#P#" $OPEN_PORTS
}

eval_echo "ports ./docker-compose.yml"
eval_echo "ports ./codenjoy.yml"
eval_echo "ports ./client-runner.yml"
eval_echo "ports ./balancer.yml"
eval_echo "ports ./wordpress.yml"

# -------------------------- BASIC AUTH --------------------------

basic_auth() {
    file=$1
    comment $file "#A#" $BASIC_AUTH
}

eval_echo "basic_auth ./config/nginx/conf.d/codenjoy/locations.conf"
eval_echo "basic_auth ./config/nginx/conf.d/balancer/locations.conf"
eval_echo "basic_auth ./config/nginx/conf.d/balancer-frontend/locations.conf"
eval_echo "basic_auth ./config/nginx/conf.d/client-runner/locations.conf"
eval_echo "basic_auth ./config/nginx/conf.d/wordpress/locations.conf"

# -------------------------- SSL --------------------------

if [ "x$SSL" = "xtrue" ]; then
    NOT_SSL="false";
else
    NOT_SSL="true";
fi

ssl() {
    file=$1
    comment $file "#S#" $SSL
    comment $file "#!S#" $NOT_SSL
}

eval_echo "ssl ./config/nginx/domain.conf"
eval_echo "ssl ./config/nginx/conf.d/applications.conf"
eval_echo "ssl ./config/nginx/conf.d/codenjoy/locations.conf"
eval_echo "ssl ./docker-compose.yml"

# -------------------------- DATABASE --------------------------

if [[ "$SPRING_PROFILES" =~ "postgres" ]]; then
    echo "[93mPostgres[0m";
    POSTGRE="true";
    SQLITE="false";
else
    echo "[93mSqlite[0m";
    POSTGRE="false";
    SQLITE="true";
fi

database() {
    file=$1
    comment $file "#L#" $SQLITE
    comment $file "#!L#" $POSTGRE

    # TODO to solve situation with multiple tags
    if [ "x$POSTGRE" = "xtrue" ] && [ "x$OPEN_PORTS" = "xtrue" ]; then
        comment $file "#!LP#" "true"
    else
        comment $file "#!LP#" "false"
    fi
}

eval_echo "database ./docker-compose.yml"
eval_echo "database ./balancer.yml"
eval_echo "database ./codenjoy.yml"


# -------------------------- CLIENT RUNNER --------------------------

if [ "x$CLIENT_RUNNER" = "xtrue" ]; then
    NOT_CLIENT_RUNNER="false";
else
    NOT_CLIENT_RUNNER="true";
fi

client-runner() {
    file=$1
    comment $file "#R#" $CLIENT_RUNNER
    comment $file "#!R#" $NOT_CLIENT_RUNNER
}

eval_echo "client-runner ./config/nginx/conf.d/applications.conf"

# -------------------------- BALANCER --------------------------

if [ "x$BALANCER" = "xtrue" ]; then
    NOT_BALANCER="false";
else
    NOT_BALANCER="true";
fi

balancer() {
    file=$1
    comment $file "#B#" $BALANCER
    comment $file "#!B#" $NOT_BALANCER
}

eval_echo "balancer ./config/nginx/conf.d/applications.conf"

# ---------------------- BALANCER FRONTEND -----------------------

if [ "x$BALANCER_FRONTEND" = "xtrue" ]; then
    NOT_BALANCER_FRONTEND="false";
else
    NOT_BALANCER_FRONTEND="true";
fi

balancerFrontend() {
    file=$1
    comment $file "#F#" $BALANCER_FRONTEND
    comment $file "#!F#" $NOT_BALANCER_FRONTEND
}

eval_echo "balancerFrontend ./config/nginx/conf.d/applications.conf"

# -------------------------- WORDPRESS --------------------------

if [ "x$WORDPRESS" = "xtrue" ]; then
    NOT_WORDPRESS="false";
else
    NOT_WORDPRESS="true";
fi

wordpress() {
    file=$1
    comment $file "#W#" $WORDPRESS
    comment $file "#!W#" $NOT_WORDPRESS
}

eval_echo "wordpress ./config/nginx/conf.d/applications.conf"

# -------------------------- CODENJOY --------------------------

if [ "x$CODENJOY" = "xtrue" ]; then
    NOT_CODENJOY="false";
else
    NOT_CODENJOY="true";
fi

codenjoy() {
    file=$1
    comment $file "#C#" $CODENJOY
    comment $file "#!C#" $NOT_CODENJOY
}

eval_echo "codenjoy ./config/nginx/conf.d/applications.conf"

# -------------------------------------------------------------