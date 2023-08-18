when going to php8, use git clone --branch=php8 https://github.com/nismoryco/Mosquitto-PHP

or https://github.com/openenergymonitor/Mosquitto-PHP

# extended "lamp" server

Servers :
- apache server
- mosquitto eclipse broker

Databases :
- mariadb
- redis

Languages :
- php
- python

Extensions :
- phpredis - https://github.com/phpredis/phpredis
- redis-py - https://github.com/redis/redis-py
- Mosquitto-PHP - https://github.com/mgdm/Mosquitto-PHP

# building

My initial goal was to build a lamp server and to use that image to install emoncms. It is abandonned as the alpine image works fine.

To build the debian/ubuntu lamp images:

```
docker build --build-arg="TARGETPLATFORM=linux/amd64" -t lamp:ubuntu20.04 ubuntu/.
docker build --build-arg="TARGETPLATFORM=linux/amd64" -t lamp:buster debian/.
```
