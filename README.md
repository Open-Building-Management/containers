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

- https://github.com/emoncms/emoncms-docker, which aims to have each part of emoncms running in separate containers.
- https://github.com/inverse/hassio-addon-emoncms/, which is an addon for HomeAssistant : https://www.home-assistant.io/

# workflows

github actions workflows produce multiarch containers for amd64, armv7 and aarch64, and Dockerfiles use the `TARGETPLATFORM` global var

if you want to try a local build on a x86_64 linux machine and don't have buildx installed, the `TARGETPLATFORM` global var will not be accessible

so when building the alpine image :

```
docker build --build-arg="TARGETPLATFORM=linux/amd64" -t alpinelamp .
```

# basic knowledge for initial testing

## start the emoncms container and initiate a command line connection

on a ***wired*** machine, start emoncms :
```
docker run --rm -p 8081:80 -p 7883:1883 -it alpinelamp
```
on the same machine running the container, you can connect access to it :
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

supposing the IP a the ***wired*** machine to be 192.168.1.53, you can post datas from your local network :
```
mosquitto_pub -h 192.168.1.53 -p 7883 -u "emonpi" -P "emonpimqtt2016" -t 'emon/test/t3' -m 43.67
```
if you dont have mosquitto_pub installed and are on a debian/ubuntu machine : `sudo apt-get install mosquitto-clients`
