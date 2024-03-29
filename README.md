Ubuntu portable script
======================

How to run server on Ubuntu?
----------------------------
Other options:
- If you want to run it on windows, you should read
[how to run the server on Windows](https://github.com/codenjoyme/codenjoy-portable-windows.git#windows-portable-script)
- If you want to run simple version of linex server, you should read 
[how to run the server on Linux (simple version)](https://github.com/codenjoyme/codenjoy-portable-linux-lite.git#linux-portable-script-simple-version)

I prepared to you this script, so you can run it on ubuntu server.
The fastest way to run this one line and follow instructions (here `codenjoy` - is a folder and `/srv` - is the place where it will be installed):
```
sudo su -c "bash <(wget -qO- https://raw.githubusercontent.com/codenjoyme/codenjoy-portable-linux/master/install.sh) /srv codenjoy" root
```
or do it step by step:
- *[Optional]* Please use [dedicated server](https://contabo.com/?show=configurator&server_id=270)
    for every 300-500 participants or [VPS](https://contabo.com/?show=configurator&vserver_id=229)
    if number of participants is less then 50.
- make sure nginx on host machine is disabled.
- this version uses docker-composer and docker. If docker/docker-compose are not installed we will do it for you by running this stuff
```
sudo bash setup-docker.sh
docker-compose --version
```
- copy all files from [this subrepo](https://github.com/codenjoyme/codenjoy-portable-linux.git)
    to `/srv/codenjoy` server folder as `root` user
- edit `.env` [file](https://github.com/codenjoyme/codenjoy/blob/master/CodingDojo/portable/linux-docker-compose/.env) or run `bash env-update.sh` to interactive update
  * **[WARNING] please use only alphanumericals characters [A-Za-z0-9] for passwords. Other characters due to escaping/unescaping may lead to errors in the application.**
  * `CONFIG=true` true always
  * `BUILD_SERVER=true` build server sources
  * `BUILD_BALANCER=false` build balancer sources
  * `BUILD_CLIENT_RUNNER=false` build websocket client runner sources
  * `TIMEZONE=Europe/Kiev` your timezone inside docker containers (for valid time in logs)
  * `CODENJOY_VERSION=1.1.3` version of docker images  that will be after build
  * `GIT_REPO=https://github.com/codenjoyme/codenjoy.git` git repository you want to build
  * `MAINTAINER_NAME=FirstName_LastName` Maintainer name (used inside git and docker containers)
  * `MAINTAINER_EMAIL=user@email.com` Maintainer email (used inside git and docker containers)
  * `REVISION=master` revision inside repository (to use master, branch name or revision id)
  * `SKIP_TESTS=true` this will be in the http://your-server.com/codenjoy-contest/
  * `CODENJOY_CONTEXT=codenjoy-contest` context of codenjoy server application
  * `BALANCER_CONTEXT=codenjoy-balancer` context of codenjoy builder application
  * `CLIENT_RUNNER_CONTEXT=codenjoy-client-runner` context of codenjoy websocket client runner application
  * `GAME=tetris,mollymage,knibert` games to build
    * comma separated for several games.
    * if `ALL` - all games
  * `SPRING_PROFILES=postgres,debug` spring profiles, comma separated
    * `sqlite` for the lightweight database (<50 participants)
    * `postgres` for the postgres database (>50 participants)
    * `trace` for enable log.debug
    * `debug` if you want to debug js files (otherwise it will compress and obfuscate)
    * `yourgame` if you added your custom configuration to the game inside `CodingDojo\games\yourgame\src\main\resources\application-yourgame.yml`
  * `PAGE_HELP_LANGUAGE=en`
    * `` for default (russian) version of how to play manuals
    * `en` for english version of how to play manuals (we will find manual here `/codenjoy-contest/resources/help/game-en.html`)       
  * `SSL=false` true - if you want to use https instead of http
    (please copy certificate here [portable/linux-docker-compose/ssl-cert](https://github.com/codenjoyme/codenjoy-portable-linux.git/ssl-cert))
  * `DOMAIN=false` true - if you want use domain instead of IP
  * `OPEN_PORTS=false` true - if you want debug all applications inside containers and want to enable port mapping (ports settings are bellow)
  * `BASIC_AUTH=false` true - if you want to set basic authorization for all game server to disable site before start contest
  * `BASIC_AUTH_LOGIN=codenjoy` basic authorization login
  * `BASIC_AUTH_PASSWORD=secureBasicAuthPassword` basic authorization password
  * `ADMIN_USER=admin@codenjoyme.com` this is user namr for admin page, please keep it secure
  * `ADMIN_PASSWORD=secureAdminPassword` this is password for admin page, please keep it secure
  * if you select postgres database - you should use this settings
    * `CODENJOY_POSTGRES_DB=codenjoy`
    * `CODENJOY_POSTGRES_USER=codenjoy`
    * `CODENJOY_POSTGRES_PASSWORD=securePostgresDBPassword`
    * `CODENJOY_POSTGRES_PORT=8004` port for codenjoy, works if `OPEN_PORTS` is true
  * please set true if you want to use wordpress at `http://your-server.com/`
    * `WORDPRESS=false`
    * `WORDPRESS_MYSQL_ROOT_PASSWORD=secureWordpressRootDBPassword`
    * `WORDPRESS_MYSQL_DATABASE=wordpress`
    * `WORDPRESS_MYSQL_USER=wordpress`
    * `WORDPRESS_MYSQL_PASSWORD=secureWordpressDBPassword`
    * `WORDPRESS_PORT=8006` port for wordpress application, works if `OPEN_PORTS` is true
    * `WORDPRESS_MYSQL_PORT=8005` port for wordpress database, works if `OPEN_PORTS` is true
  * true if you want to setup pgadmin for postgres on this server
    * `PGADMIN=false`
    * `PGADMIN_DEFAULT_PASSWORD=securePGAdminPassword`
    * `PGADMIN_DEFAULT_EMAIL=your@email.com`
    * `PGADMIN_PORT=8007` port for pgadmin, works if `OPEN_PORTS` is true
  * domain settings (if `DOMAIN=false` please ignore this option) (uses in nginx setup)
  * `SERVER_IP=79.143.176.243` your IP
  * `SERVER_DOMAIN=your-domain.com` your domain
  * true if you want to run load websocket client runner on this server
      * `CLIENT_RUNNER=false`
      * `CLIENT_RUNNER_PORT=8009` port for this application, works if `OPEN_PORTS` is true 
      * `CLIENT_RUNNER_SOLUTION_FOLDER_PATH=./solutions` sources folder inside application forlder (in docker contsiner) 
      * `CLIENT_RUNNER_SOLUTION_FOLDER_PATTERN=dd-MM-yyyy'T'HH_mm_ss` sources timestamp folder pattern
      * `CLIENT_RUNNER_CODENJOY_URL_REGEX=^http://domain.com/codenjoy-contest/board/player/([\\w]+)\\?code=([\\w]+)` websocket client connection url pattern
  * true if you want to run load balancer on this server
    * `BALANCER=false`
    * `BALANCER_PORT=8001` port for balancer backend, works if `OPEN_PORTS` is true
    * `BALANCER_SMS_ENABLED=false` enable sms registration verification
    * `BALANCER_GAME_SERVERS=game1.your.domain.com,game2.your.domain.com,game3.your.domain.com` list of game servers, comma separated, works if `BALANCER` is true
    * `BALANCER_GAME_ROOM=10` players per one room
    * `BALANCER_GAME_START_DAY=2020-03-01` game tournament start day
    * `BALANCER_GAME_END_DAY=2020-03-31` game tournament end day
    * `BALANCER_GAME_EXCLUDED_DAYS=2020-03-06,2020-03-07` game tournament weekends (comma separated value)
    * `BALANCER_GAME_FINALISTS_COUNT=10` day finalists count 
    * `BALANCER_GAME_FINAL_TIME=19:00` game tournament end time
  * balancer frontend settings list
    * `BALANCER_FRONTEND=false`
    * `BALANCER_FRONTEND_PORT=8003` port for balancer frontend, works if `OPEN_PORTS` is true
    * `NODE_PATH=src/` please do not change it, I don't know what it is )
    * `GENERATE_SOURCEMAP=false` please do not change it, I don't know what it is )
    * `REACT_APP_API_SERVER=https://your-domain.io` Link to balancer backend server (to use `https` when `SSL=true`)
    * `REACT_APP_GAME=mollymage` game to choose (please select only one same game here and in the `GAME` property)
    * `REACT_APP_EVENT_START=2020-03-01T07:00:00.000Z` game tournament start day/time
    * `REACT_APP_EVENT_END=2020-03-31T17:00:00.000Z` game tournament end day/time
    * `REACT_APP_EVENT_LINK=http://your-event.io` Link to event
    * `REACT_APP_JOIN_CHAT_LINK=https://your-chat.io` Link to chat
    * `REACT_APP_GA_ID=UA-123456789-1` 
    * `REACT_APP_FB_PIXEL_ID=123456789012345` facebook pixel
    * `REACT_APP_IS_SECURE=true` please set true if `SSL=true`
    * `REACT_APP_IS_UNAVAILABLE=false` please set true if application is unavaliable
    * `REACT_APP_EVENT_START_DATE=01.03.2020` game tournament start day (info page only)
    * `REACT_APP_EVENT_END_DATE=31.03.2020` game tournament end day (info page only)
    * `REACT_APP_EVENT_REGISTER_END_DATE=31.03.2020` game tournament registration end day (info page only)
    * `REACT_APP_EVENT_START_TIME=09:00` game tournament start time (info page only)
    * `REACT_APP_EVENT_FINAL_TIME=19:00` game tournament final time (info page only)
    * `REACT_APP_EVENT_FINALISTS_COUNT=10` day finalists count (info page only)
    * `REACT_APP_EVENT_ORG_EMAIL=your@email.com` Organizer contact email  
    * `REACT_APP_SCORES_UPDATE_TIMEOUT=10000` Time in mills to update scores leaderboard page
  * `CODENJOY=true` if you want to run codenjoy app on this server (only one app `BALANCER` | `CODENJOY` should be)
  * `CODENJOY_PORT=8002` port for codenjoy application, works if `OPEN_PORTS` is true
  * `CODENJOY_GAME_AI=true` If you want to launch AI bot in the room with the first participant. So the participant will not be bored to play himself. 
  * `CODENJOY_GAME_SAVE_AUTO=true` If you want to save all scores (backup) every 30 ticks. 
  * `CODENJOY_GAME_SAVE_LOAD_ON_START=true` If you want to load all scores from saves during server starting. 
  * `CODENJOY_XFRAMEALLOWEDHOSTS=domain.com` Domain ot IP of this server. 
  * `CODENJOY_PAGE_MAIN_UNAUTHORIZED=true` If you allow access to the main page with 
        the ability to view server games for an unregistered user please set `true` here, 
        otherwise there will be a redirect to login    
- build and start server by command (everytime when you committed new changes)
```
sudo bash rebuild.sh
```
- restart server if need
```
sudo bash up.sh
```
- now you can press Ctrl-F5 (for clean browser cache) and register
[http://127.0.0.1:8080/codenjoy-contest](http://127.0.0.1:8080/codenjoy-contest)


Useful commands
---------------
- how to get logs from docker images?
```
sudo bash log.sh nginx
sudo bash log.sh codenjoy_db
sudo bash log.sh codenjoy_server
```
- where is application logs?
```
./logs/
```
- where is database?
```
./materials/
```
- where is applications?
```
./applications/
```
- where is config (nginx / codenjoy)? Be carefull this folder will update every time you run any command this manual
```
./config/
```
- where is my ssl certificates?
```
./ssl-cert/
./config/nginx/ssl.conf
```
- how to backup/restore postgres database?
```
cd ./materials & sudo bash backup.sh
cd ./materials & sudo bash restore.sh
```
- how to check all user saves?
```
cd ./materials & sudo bash get-user-saves.sh "Stiven Pupkin"
```
- how to get all users?
```
cd ./materials & sudo bash get-users.sh
```
- hot to check current git revision?
```
cd ./applications & sudo bash check-revision.sh
```
- if you run any command please create bash script and share it with us - it can be useful for us.
```
echo "Be LAZY write script"
```

Other materials
--------------
For [more details, click here](https://github.com/codenjoyme/codenjoy#codenjoy)

[Codenjoy team](http://codenjoy.com/portal/?page_id=51)
===========