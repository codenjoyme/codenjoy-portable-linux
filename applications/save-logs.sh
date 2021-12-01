#!/usr/bin/env bash
now=`date +%Y-%m-%d"_"%H-%M-%S`
for container in `docker ps -a --format '{{.Names}}'`; do
    echo Processing ./$now/$container.log
    mkdir -p $now
    docker logs $container 2>&1 | cat > ./$now/$container.log
done

echo Make archive
tar -zcvf ./$now.tar.gz ./$now && rm -R ./$now

echo Done