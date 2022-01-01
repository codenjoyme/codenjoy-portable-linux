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

if [ -x "$(command -v git)" ]; then
    echo "[Git installed[0m" ;
else
    eval_echo "sudo apt update"
    eval_echo "sudo apt install git"
    eval_echo "git --version"
fi

base=${1:=/srv}
folder=${2:=codenjoy}

eval_echo "cd $base && ls -la"
eval_echo "git clone https://github.com/codenjoyme/codenjoy-portable-linux.git $folder"
eval_echo "cd ./$folder && ls -la"

DIR=$base/$folder

eval_echo ". env-update.sh"
eval_echo ". rebuild.sh"