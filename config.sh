#!/usr/bin/env bash

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

eval_echo "parameter ./config/nginx/conf.d/codenjoy.conf 'server_name ' $SERVER_DOMAIN ';'"

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
eval_echo "ports ./balancer.yml"
eval_echo "ports ./wordpress.yml"

# -------------------------- BASIC AUTH --------------------------

basic_auth() {
    file=$1
    comment $file "#A#" $BASIC_AUTH
}

eval_echo "basic_auth ./config/nginx/conf.d/codenjoy.conf"
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
eval_echo "ssl ./config/nginx/conf.d/codenjoy.conf"
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

eval_echo "wordpress ./config/nginx/conf.d/codenjoy.conf"

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

    # TODO to solve situation with multiple tags
    if [ "x$BALANCER" = "xtrue" ]; then
        comment $file "#AB#" $BASIC_AUTH
    fi
}

eval_echo "balancer ./config/nginx/conf.d/codenjoy.conf"

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

    # TODO to solve situation with multiple tags
    if [ "x$BALANCER_FRONTEND" = "xtrue" ]; then
        comment $file "#AF#" $BASIC_AUTH
    fi
}

eval_echo "balancerFrontend ./config/nginx/conf.d/codenjoy.conf"

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

    # TODO to solve situation with multiple tags
    if [ "x$NOT_WORDPRESS" = "xtrue" ] && [ "x$NOT_BALANCER_FRONTEND" = "xtrue" ]; then
        comment $file "#!W!F#" "true"
        comment $file "#!S!W!F#" $NOT_SSL
        comment $file "#S!W!F#"  $SSL
    else
        comment $file "#!W!F#" "false"
        comment $file "#!S!W!F#" "false"
        comment $file "#S!W!F#"  "false"
    fi
}

eval_echo "wordpress ./config/nginx/conf.d/codenjoy.conf"

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

    # TODO to solve situation with multiple tags
    if [ "x$CODENJOY" = "xtrue" ]; then
        comment $file "#AC#" $BASIC_AUTH
    fi
}

eval_echo "codenjoy ./config/nginx/conf.d/codenjoy.conf"

# --------------------------         --------------------------