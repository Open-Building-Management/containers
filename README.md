# a container for the emoncms stack : why ?

Based on the s6-overlay init system : https://github.com/just-containers/s6-overlay/

emoncms is a very nice piece of software in the world of real time data monitoring

it uses : 
- a self crafted binary timeserie called phpfina and mariadb to store metadatas
- the eclipse mosquitto broker
- redis as a data buffer when writing to disk on timeseries
- three main workers to achieve background operations : emoncms_mqtt, service-runner and feedwriter

The web app, traditionnaly running on a apache2 webserver, has got a MVC architecture and is structured around modules. The most universal ones are graph, postprocess, sync, dashboard and backup. 

Usually, emoncms is installed through a collection of scripts : cf https://github.com/openenergymonitor/EmonScripts, as it is intended to work on hardware (such as the emonpi) designed by the openenergymonitor startup : https://openenergymonitor.org/

To speed up emoncms use on other platforms, it should be convenient to have a container bringing together the web app and the universal modules, the databases, the mqtt broker and the main services

Several attempts to port emoncms to container architecture are worth mentioning :

- https://github.com/emoncms/emoncms-docker, which aims to have each part of emoncms running in separate containers. Anyway the project introduced the use of supervisord (http://supervisord.org/) to run multiple services in the same container
- https://github.com/inverse/hassio-addon-emoncms/, an addon for HomeAssistant (https://www.home-assistant.io) using s6-overlay but not yet ready for stable use 

# building

github actions workflows produce multiarch containers for amd64, armv7 and aarch64, and Dockerfiles use the `TARGETPLATFORM` global var

if you want to try a local build on a x86_64 linux machine and don't have buildx installed, the `TARGETPLATFORM` global var will not be accessible

To build the alpine image :

```
docker build --build-arg="TARGETPLATFORM=linux/amd64" -t emoncms:alpine3.16 emoncms/alpine.
```

Initially working on ubuntu, I switched to alpine to see if it could be possible to produce a smaller image

The ubuntu/debian process was organise in two separate phases : 
- build a lamp image
- use that image to install emoncms

To build the debian/ubuntu images:

```
docker build --build-arg="TARGETPLATFORM=linux/amd64" -t emoncms:ubuntu20.04 lamp/ubuntu.
docker build --build-arg="TARGETPLATFORM=linux/amd64" -t emoncms:buster lamp/debian.
```

# basic knowledge for initial testing

## start the emoncms container

on a ***wired*** machine, start emoncms :
```
docker run --rm -p 8081:80 -p 7883:1883 -it emoncms:alpine3.16
```
## initiate a command line connection

on the same machine running the container, start another terminal :
```
docker container ls
CONTAINER ID   IMAGE        COMMAND                  CREATED          STATUS          PORTS                                                                              NAMES
260141ad1f2f   alpinelamp   "/init"                  46 minutes ago   Up 46 minutes   0.0.0.0:8081->80/tcp, :::8081->80/tcp, 0.0.0.0:7883->1883/tcp, :::7883->1883/tcp   sweet_meitner
```
then `docker exec -it 260141ad1f2f bash`

### to check the SQL database

`mysql` then `SHOW DATABASES;`

### to test redis

`redis-cli` then `keys *`

## post datas to the broker

supposing the IP of the ***wired*** machine running emoncms to be 192.168.1.53, you can post datas from your local network :
```
mosquitto_pub -h 192.168.1.53 -p 7883 -u "emonpi" -P "emonpimqtt2016" -t 'emon/test/t3' -m 43.67
```
if you dont have mosquitto_pub installed and are on debian/ubuntu : `sudo apt-get install mosquitto-clients`

## shutdown the container 

`docker stop 260141ad1f2f`
