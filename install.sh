#!/usr/bin/env bash
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

eval_echo "git clone https://github.com/codenjoyme/codenjoy-portable-linux.git codenjoy"
eval_echo "cd ./codenjoy"
ls -la

eval_echo ". env-update.sh"
eval_echo ". rebuild.sh"