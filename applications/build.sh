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

echo "[92m========================================================================================================================"
echo "================================================= Building applications ================================================"
echo "========================================================================================================================[0m"

if [ "x$GIT_REPO" = "x" ]; then
    cd ..
    . ./dir.sh
    . ./config.sh 
    cd ./applications
fi

if [ "x$GIT_REPO" = "x" ]; then
    echo "[91mPlease run this script from its folder[0m"
    exit
fi

echo "[93m"
echo "BUILD_SERVER=$BUILD_SERVER"
echo "BUILD_BALANCER=$BUILD_BALANCER"
echo "BUILD_CLIENT_RUNNER=$BUILD_CLIENT_RUNNER"
echo "TIMEZONE=$TIMEZONE"
echo "GIT_REPO=$GIT_REPO"
echo "MAINTAINER_NAME=$MAINTAINER_NAME"
echo "MAINTAINER_EMAIL=$MAINTAINER_EMAIL"
echo "REVISION=$REVISION"
echo "GAME=$GAME"
echo "SKIP_TESTS=$SKIP_TESTS"
echo "[0m"

eval_echo() {
    to_run=$1
    echo "[94m"
    echo $to_run
    echo "[0m"

    eval $to_run
}

rm -rf ./logs
mkdir ./logs

# build java-workspace
if [[ "$(docker images -q java-workspace 2> /dev/null)" == "" ]]; then
    echo "[92m========================================================================================================================" ;
    echo "================================================ Building java-workspace ===============================================" ;
    echo "========================================================================================================================[0m" ;

    # prepare java-workspace image update system && set timezone
    eval_echo "docker build --progress=plain --target java_workspace -t java-workspace -f Dockerfile ./ --build-arg TIMEZONE=${TIMEZONE} |& tee ./logs/java-workspace.log" ;
else
    echo "[93mImage java-workspace already installed[0m" ;
fi

# checkout if needed
if [[ "$(docker images -q codenjoy-source 2> /dev/null)" == "" ]]; then
    echo "[92m========================================================================================================================" ;
    echo "======================================== Codenjoy sources not found. Checking out =======================================" ;
    echo "========================================================================================================================[0m" ;

    # checkout and build project
    eval_echo "docker build --progress=plain --target codenjoy_source -t codenjoy-source -f Dockerfile ./ --build-arg GIT_REPO=${GIT_REPO} --build-arg MAINTAINER_NAME=${MAINTAINER_NAME} --build-arg MAINTAINER_EMAIL=${MAINTAINER_EMAIL} --build-arg REF=${REVISION} |& tee ./logs/codenjoy-source.log" ;
else
    echo "[93mImage codenjoy-source already installed[0m" ;
fi

echo "[92m========================================================================================================================"
echo "=============================================== Checking out last version =============================================="
echo "========================================================================================================================[0m"

eval_echo "docker container rm temp --force"
eval_echo "docker run --name temp -v $DIR/materials/maven:/root/.m2 -d codenjoy-source tail -f /dev/null"
eval_echo "docker exec temp bash -c 'cd /tmp/codenjoy && git clean -fx'"
eval_echo "docker exec temp bash -c 'cd /tmp/codenjoy && git reset --hard'"
eval_echo "docker exec temp bash -c 'cd /tmp/codenjoy && git fetch --all'"
eval_echo "docker exec temp bash -c 'cd /tmp/codenjoy && git pull --recurse-submodules origin'"
eval_echo "docker exec temp bash -c 'cd /tmp/codenjoy && git submodule update --remote --init'"
eval_echo "docker exec temp bash -c 'cd /tmp/codenjoy && git checkout ${REVISION}'"
eval_echo "docker exec temp bash -c 'cd /tmp/codenjoy && git fetch'"
eval_echo "docker exec temp bash -c 'cd /tmp/codenjoy && git status'"
eval_echo "sleep 5"

echo "[92m========================================================================================================================"
echo "=============================================== Save sources after update ==============================================="
echo "========================================================================================================================[0m"

MVNW=/tmp/codenjoy/CodingDojo/mvnw
eval_echo "docker exec temp bash -c 'cd /tmp/codenjoy/CodingDojo && $MVNW clean'"
eval_echo "docker commit temp codenjoy-source"

echo "[92m========================================================================================================================"
echo "=============================================== Building codenjoy server ==============================================="
echo "========================================================================================================================[0m"

if [ "x$BUILD_SERVER" = "xtrue" ]; then
    if [ "x$GAME" = "x" ] || [ "x$GAME" = "xALL" ]; then
        # build all projects and server with all games
        eval_echo "docker exec temp bash -c 'cd /tmp/codenjoy/CodingDojo && $MVNW clean install -DallGames -DskipTests=$SKIP_TESTS' |& tee ./logs/codenjoy-deploy.log" ;
    else
        # build games parent
        eval_echo "docker exec temp bash -c 'cd /tmp/codenjoy/CodingDojo/games && $MVNW clean install -N -DskipTests=$SKIP_TESTS' |& tee ./logs/codenjoy-deploy.log" ;

        # build java client
        eval_echo "docker exec temp bash -c 'cd /tmp/codenjoy/CodingDojo/clients/java && $MVNW clean install -DskipTests=$SKIP_TESTS' |& tee ./logs/codenjoy-deploy.log" ;

        # build engine
        eval_echo "docker exec temp bash -c 'cd /tmp/codenjoy/CodingDojo/games/engine && $MVNW clean install -DskipTests=$SKIP_TESTS' |& tee ./logs/codenjoy-deploy.log" ;

        # build game
        eval_echo "docker exec temp bash -c 'cd /tmp/codenjoy/CodingDojo/games/$GAME && $MVNW clean install -DskipTests=$SKIP_TESTS' |& tee ./logs/codenjoy-deploy.log" ;

        # build server with selected game
        eval_echo "docker exec temp bash -c 'cd /tmp/codenjoy/CodingDojo/server && $MVNW clean install -P$GAME -DskipTests=$SKIP_TESTS' |& tee ./logs/codenjoy-deploy.log" ;
    fi
    eval_echo "docker exec temp bash -c 'cd /tmp/codenjoy/CodingDojo/server/target && ls -la'"
    eval_echo "docker cp temp:/tmp/codenjoy/CodingDojo/server/target/${CODENJOY_CONTEXT}.war ./${CODENJOY_CONTEXT}.war" ;
    ls -la ./${CODENJOY_CONTEXT}.war
fi
    
echo "[92m========================================================================================================================"
echo "========================================== Building balancer server / front ============================================"
echo "========================================================================================================================[0m"

if [ "x$BUILD_BALANCER" = "xtrue" ] ;
then
    # build engine
    eval_echo "docker exec temp bash -c 'cd /tmp/codenjoy/CodingDojo/games/engine && $MVNW clean install -DskipTests=$SKIP_TESTS' |& tee ./logs/codenjoy-deploy.log" ;

    # build balancer
    eval_echo "docker exec temp bash -c 'cd /tmp/codenjoy/CodingDojo/balancer && $MVNW clean install -DskipTests=$SKIP_TESTS' |& tee ./logs/balancer-deploy.log" ;
    eval_echo "docker cp temp:/tmp/codenjoy/CodingDojo/balancer/target/${BALANCER_CONTEXT}.war ./${BALANCER_CONTEXT}.war" ;
	  ls -la ./${BALANCER_CONTEXT}.war

    # build balancer-frontend
    eval_echo "rm -rf ./codenjoy-balancer-frontend/*" ;
    eval_echo "docker cp temp:/tmp/codenjoy/CodingDojo/balancer-frontend/ ./" ;
    ls -la ./balancer-frontend/
    eval_echo "cp ./../.env ./balancer-frontend/" ;
    ls -la ./balancer-frontend/.env
fi

echo "[92m========================================================================================================================"
echo "============================================= Building client runner ==============================================="
echo "========================================================================================================================[0m"

if [ "x$BUILD_CLIENT_RUNNER" = "xtrue" ] ;
then
    # build dockerized-java-workspace
    if [[ "$(docker images -q dockerized-java-workspace 2> /dev/null)" == "" ]]; then
        # prepare dockerized-java-workspace
        eval_echo "docker build --progress=plain --target dockerized_java_workspace -t dockerized-java-workspace -f Dockerfile-client-runner ./ |& tee ./logs/dockerized-java-workspace.log" ;
    else
        echo "[93mImage dockerized-java-workspace already installed[0m" ;
    fi

    # build client-runner
    eval_echo "docker exec temp bash -c 'cd /tmp/codenjoy/CodingDojo/client-runner && $MVNW clean install -DskipTests=$SKIP_TESTS' |& tee ./logs/client-runner-deploy.log" ;
    eval_echo "docker cp temp:/tmp/codenjoy/CodingDojo/client-runner/target/${CLIENT_RUNNER_CONTEXT}.war ./${CLIENT_RUNNER_CONTEXT}.war" ;
	  ls -la ./${CLIENT_RUNNER_CONTEXT}.war
fi

echo "[92m========================================================================================================================"
echo "=================================================== Cleaning stuff ===================================================="
echo "========================================================================================================================[0m"

eval_echo "docker container rm temp --force"

eval_echo "docker image ls"
eval_echo "docker ps -a"
eval_echo "docker network ls"

eval_echo "bash check-revision.sh"
