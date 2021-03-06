#!/usr/bin/env bash
if [ "$EUID" -ne 0 ]
  then echo "[91mPlease run as root[0m"
  exit
fi

bash setup-docker.sh

echo "[92m========================================================================================================================"
echo "==================================================== Init structure ===================================================="
echo "========================================================================================================================[0m"

if [ "x$BASIC_AUTH_LOGIN" = "x" ]; then
    . config.sh ;
fi

if [ "x$BASIC_AUTH_PASSWORD" = "x" ]; then
    . config.sh ;
fi

if [ "x$TIMEZONE" = "x" ]; then
    . config.sh ;
fi

if [ "x$SPRING_PROFILES" = "x" ]; then
    . config.sh ;
fi

eval_echo() {
    to_run=$1
    echo "[94m"
    echo $to_run
    echo "[0m"

    eval $to_run
}

eval_echo "unlink /etc/localtime & ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime"
sudo dpkg-reconfigure -f noninteractive tzdata

# for nginx
generate_htpasswd() {
    rm ./config/nginx/.htpasswd
    touch ./config/nginx/.htpasswd
    sudo sh -c "echo -n '$BASIC_AUTH_LOGIN:' >> ./config/nginx/.htpasswd"
    sudo sh -c "openssl passwd -apr1 $BASIC_AUTH_PASSWORD >> ./config/nginx/.htpasswd"
    cat ./config/nginx/.htpasswd
}
eval_echo "generate_htpasswd"

eval_echo "chown root:root ./ssl-cert/*"
ls -la ./ssl-cert

eval_echo "chown root:root ./config/nginx/*"
ls -la ./config/nginx

# maven
eval_echo "mkdir -p ./materials/maven"
eval_echo "chown root:root ./materials/maven"
ls -la ./materials/maven

# database
eval_echo "mkdir -p ./materials/codenjoy/database"
eval_echo "chown root:root ./materials/codenjoy/database"
ls -la ./materials/codenjoy/database

# client runner
eval_echo "mkdir -p ./materials/client-runner/sources"
eval_echo "chown root:root ./materials/client-runner/sources"
ls -la ./materials/client-runner/sources

# for codenjoy_balancer / codenjoy_contest
eval_echo "mkdir -p ./config/codenjoy"
eval_echo "chown root:root ./config/codenjoy"
ls -la ./config/codenjoy

# logs
eval_echo "mkdir -p ./logs/codenjoy"
eval_echo "mkdir -p ./logs/client-runner"
# TODO uncomment when fix
# eval_echo "touch ./logs/codenjoy/codenjoy-balancer.log"
# eval_echo "touch ./logs/codenjoy/codenjoy-contest.log"
# eval_echo "chown root:root ./logs/codenjoy/codenjoy-balancer.log"
# eval_echo "chown root:root ./logs/codenjoy/codenjoy-contest.log"
ls -la ./logs/codenjoy
