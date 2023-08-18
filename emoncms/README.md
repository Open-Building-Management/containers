The "root" [Dockerfile](Dockerfile) uses the lamp image, but I switched to alpine as it produces smaller images.

The alpine folder is working but without data persistency

The alpine_persistent folder is the final Dockerfile

# a container for the emoncms stack : why ?

Based on the s6-overlay init system : https://github.com/just-containers/s6-overlay/

[emoncms](https://github.com/emoncms/emoncms) is a very nice piece of software in the world of real time data monitoring

it uses : 
- a self crafted binary timeserie called [phpfina](https://github.com/emoncms/emoncms/tree/master/docs/timeseries) and mariadb to store metadatas. You can exploit recorded feeds as python numpy arrays using the [PyFina library](https://github.com/Open-Building-Management/PyFina).
- the eclipse mosquitto broker
- redis as a data buffer when writing to disk on timeseries
- three main workers to achieve background operations : emoncms_mqtt, service-runner and feedwriter

The web app, traditionnaly running on a apache2 webserver, has got a MVC architecture and is structured around modules. The most universal ones are graph, postprocess, sync, dashboard and backup. 

Usually, emoncms is installed through a collection of [scripts](https://github.com/openenergymonitor/EmonScripts), mostly intended to work on hardware designed by the [openenergymonitor startup](https://openenergymonitor.org), such as the [emonpi](https://github.com/openenergymonitor/emonpi). These scripts are specific to raspian/ubuntu architectures, and make extensive use of : 
- debian tricks like a2enconf, a2ensite, a2dissite, phpenmod...
- sudo, as they are launched after (and by) the first system user (a sudoer) has been created,
- systemctl, the service manager of the systemd init system.

To speed up emoncms use on other platforms, it should be convenient to have a container bringing together the web app and the universal modules, the databases, the mqtt broker and the main workers

Several attempts to port emoncms to container architecture are worth mentioning :

- https://github.com/emoncms/emoncms-docker, which aims to have each part of emoncms running in separate containers. Anyway the project introduced the use of [supervisord](http://supervisord.org/) to run multiple services in the same container
- https://github.com/inverse/hassio-addon-emoncms/, an addon for [HomeAssistant](https://www.home-assistant.io) using s6-overlay and nginx as the web server but not yet ready for stable use
- https://github.com/jakezp/emoncms, unmaintained for the last 4 years only for amd64 architecture

# building

[github actions workflows](https://github.com/Open-Building-Management/containers/actions) produce multiarch containers for amd64, armv7 and aarch64, and Dockerfiles use the `TARGETPLATFORM` global var

if you want to try a local build on a x86_64 linux machine and don't have buildx installed, the `TARGETPLATFORM` global var will not be accessible

To build the alpine persistent image from HERE :

```
docker build --build-arg="TARGETPLATFORM=linux/amd64" -t emoncms:alpine3.16 alpine_persistent/.
```


# basic knowledge for initial testing

## start the emoncms container

```
docker run --rm -p 8081:80 -p 7883:1883 -it emoncms:alpine3.16
```

if you want persistent datas, create a folder named data on the host and start emoncms with a volume :

```
docker run --rm -p 8081:80 -p 7883:1883 -v /data:/data -it emoncms:alpine3.16
```

## bash connection to the container

on the same machine running the container, start another terminal :
```
docker container ls
CONTAINER ID   IMAGE        COMMAND                  CREATED          STATUS          PORTS                                                                              NAMES
260141ad1f2f   alpinelamp   "/init"                  46 minutes ago   Up 46 minutes   0.0.0.0:8081->80/tcp, :::8081->80/tcp, 0.0.0.0:7883->1883/tcp, :::7883->1883/tcp   sweet_meitner
```
then `docker exec -it 260141ad1f2f bash`

### check the SQL database

`mysql` then `SHOW DATABASES;`

### test redis

`redis-cli` then `keys *`

## post datas to the broker

supposing the IP of the ***wired*** machine running emoncms to be 192.168.1.53, you can post datas from your local network :
```
mosquitto_pub -h 192.168.1.53 -p 7883 -u "emonpi" -P "emonpimqtt2016" -t 'emon/test/t3' -m 43.67
```
if you dont have mosquitto_pub installed and are on debian/ubuntu : `sudo apt-get install mosquitto-clients`

if the machine running emoncms is not ***wired***, just wifi, I think you will not be able to communicate with the broker from your local network. To test on the same machine, use `127.0.0.1` instead of the local IP.

## shutdown the container 

`docker stop 260141ad1f2f`
