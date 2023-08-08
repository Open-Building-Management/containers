# a container for the emoncms stack : why ?

Based on the s6-overlay init system : https://github.com/just-containers/s6-overlay/

emoncms is a very nice piece of software in the world of real time data monitoring

it uses : 
- a self crafted binary timeserie called phpfina and mariadb to store metadatas
- the eclipse mosquitto broker
- redis as a data buffer when writing collected datas on disk
- three main workers to achieve background operations : emoncms_mqtt, service-runner and feedwriter

The web app, traditionnaly running on a apache2 webserver, has got a MVC architecture and is structured around modules. The most universal ones are graph, postprocess, sync, dashboard and backup. 

Usually, emoncms is installed through a collection of scripts : cf https://github.com/openenergymonitor/EmonScripts, as it is intended to work on hardware (such as the emonpi) designed by the openenergymonitor startup : https://openenergymonitor.org/

To speed up emoncms use on other platforms, it should be convenient to have a container bringing together the web app and the universal modules, the databases, the broker and the main services


# workflows

github actions workflows produce multiarch containers for amd64, armv7 and aarch64, and Dockerfiles use the TARGETPLATFORM global var

if you want to try a local build on a x86_64 linux machine and don't have buildx installed, the TARGETPLATFORM global var will not be accessible

so when building the alpine image :

```
docker build --build-arg="TARGETPLATFORM=linux/amd64" -t alpinelamp .
```


