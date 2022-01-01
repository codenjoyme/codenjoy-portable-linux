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

eval_echo() {
    to_run=$1
    echo "[94m"
    echo $to_run
    echo "[0m"

    eval $to_run
}

if [ -x "$(command -v docker)" ]; then
    echo "[93mDocker installed[0m" ;

    if [ -x "$(command -v docker-compose)" ]; then
        echo "[93mDocker comopose installed[0m" ;
        exit ;
    fi
fi

echo "[92m========================================================================================================================"
echo "================================================== Installing Docker ==================================================="
echo "========================================================================================================================[0m"

# setup docker
eval_echo "apt-get remove docker docker-engine docker.io containerd runc"
eval_echo "apt-get -y update"
eval_echo "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
eval_echo "apt-key fingerprint 0EBFCD88"

# for debian alpine
# eval_echo 'apt-get install -y software-properties-common'
# eval_echo 'add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(dpkg --status tzdata|grep Provides|cut -f2 -d'-') stable"'

# for ubuntu
eval_echo 'add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"'

eval_echo "apt-get update -y"
eval_echo "apt-get install docker-ce docker-ce-cli containerd.io -y"
eval_echo "systemctl status docker --no-pager"
eval_echo "usermod -aG docker $USER"
eval_echo "docker -v"
	
# setup compose
eval_echo "curl -L 'https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)' -o /usr/local/bin/docker-compose"
eval_echo "chmod +x /usr/local/bin/docker-compose"
eval_echo "docker-compose --version"
