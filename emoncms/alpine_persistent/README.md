# An alpine container with persistent storage

## changes with the initial alpine Dockerfile

- a oneshot s6 service called emoncms_pre to create the timeseries folders, fix permissions and run mysql_install_db if needed

- a oneshot s6 service called sql_ready initializes the emoncms database if needed and waits for mariadb to be running, before the workers can start

Using environnement variables, emoncms_pre.sh generates at startup the following conf files :
- /etc/my.cnf
- emoncms settings.ini
- config.cfg for backup module
- backup.ini PHP extension

Even if mariadb tables initialisation is done when the first user is created, as we are going to use something like docker compose, we need the database structure to be created before, and so we still use emoncmsdbupdate.php

## Some ENV vars are both used during buildtime and during runtime

ENV|Dockerfile|makefile (used during build)|emoncms_pre|mysql_ready|ARG
--|--|--|--|--|--
DAEMON|10||2||
WWW|9|X|2||
OEM_DIR|6||2|1|
EMONCMS_DIR|5|X|3||
EMONCMS_LOG_LOCATION|4||||
MQTT_CONF|1||7||
PHP_VER|2||||YES
PHP_CONF|2||3||YES

## real ENV vars, only used at runtime
ENV|Dockerfile|makefile (used during build)|emoncms_pre|mysql_ready|ARG
--|--|--|--|--|--
TZ|||1||
EMONCMS_DATADIR|||15||
TS|||1||
MYSQL_DATABASE|||1|3|
MYSQL_USER|||1|3|
MYSQL_PASSWORD|||1|1|
MQTT_USER|||2||
MQTT_PASSWORD|||2||
MQTT_HOST|||1||
MQTT_LOG_LEVEL|||1||


## changelog

### 29/09/2023

adding ARG BUILD_FROM

defining PHP_VER and PHP_CONF as ARG and no more as ENV, so we can modulate PHP_VER and PHP_CONF during build, in order to be able to build for alpine:3.18 without changing anything

```
docker build -t emoncms:alpine3.18 --build-arg="BUILD_FROM=alpine:3.18" --build-arg="TARGETPLATFORM=linux/amd64" --build-arg="PHP_VER=81" --build-arg="PHP_CONF=/etc/php81/conf.d" .
```

nota : PHP_CONF is also defined as an ENV at the end of the dockerfile as we use it in emoncms_pre

### 21/09/2023

solving timezone problem with the command `cp /usr/share/zoneinfo/$TZ /etc/localtime` in emoncms_pre

possibility to modulate mqtt log level :

```
docker run --rm -it -p 8081:80 -p 7883:1883 -e MQTT_LOG_LEVEL="error warning information notice" themis:alpine3.16
docker run --rm -it -p 8081:80 -p 7883:1883 -e MQTT_LOG_LEVEL=notice themis:alpine3.16
```

### 31/01/2024

trying to add ssl and https

introduction of 2 new ENV vars : CRT_FILE and KEY_FILE

```
sudo docker run --rm -p 8081:80 -p 8082:443 -p 7883:1883 -v /etc/ssl/certs/bios:/cert -e CRT_FILE=/cert/alexjunk.crt -e KEY_FILE=/cert/alexjunk.key -it emoncms:alpine3.18
```
