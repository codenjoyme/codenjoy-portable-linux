docker run --name temp -d codenjoy-source
docker exec -it temp bash
cd /tmp/codenjoy/

# do your homework

docker commit temp codenjoy-source
docker container rm temp --force 
