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

echo "[93mProcessing '.env' file line by line. Enter the new value, or press ENTER for the default.[0m"

for entry in $(cat ./.env)
do
    if [[ -z "${entry// }" ]]; then
        continue
    fi

    if [[ $entry == \#* ]]; then
        continue
    fi

    key=$(echo $entry | awk -F= '{print $1}')
    value=$(echo $entry | awk -F= '{print $2}')

    if [[ $key == "GAME" ]]; then
        echo "# games list (comma separated value) or 'ALL' for all games"
    fi

    if [[ $value == *"Password"* ]]; then
        new_password=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
        value=$new_password
    fi

    echo "[94m$key[0m=[91m$value[0m"

    read -p "[94m$key[0m=[91m" new_value

    echo "[0m"

    if ! [[ -z "${new_value// }" ]]; then
        value=$new_value
    fi

    escaped_value=$(printf '%s\n' "$value" | sed -e 's/[\/&]/\\&/g')
    sed -i '.env' -e "/^$key=/s/=.*/=$escaped_value/"
done