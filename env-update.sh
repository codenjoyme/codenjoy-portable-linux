#!/usr/bin/env bash

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

    sed -i '.env' -e "/^$key=/s/=.*/=$value/"

    echo ""
done