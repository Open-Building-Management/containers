# running a one shot service printing env var

for more on env vars and s6-overlay : https://github.com/just-containers/s6-overlay/issues/46

to build, supposing you are in this `basic` folder

```
docker build --build-arg="TARGETPLATFORM=linux/amd64" -t basic .
```

then run :

```
docker run --rm -it basic
s6-rc: info: service s6rc-oneshot-runner: starting
s6-rc: info: service s6rc-oneshot-runner successfully started
s6-rc: info: service fix-attrs: starting
s6-rc: info: service fix-attrs successfully started
s6-rc: info: service legacy-cont-init: starting
s6-rc: info: service legacy-cont-init successfully started
s6-rc: info: service foo: starting
HOSTNAME=696e5177f3a9
SHLVL=3
HOME=/root
EMONCMS_DATADIR=/var/opt/emoncms
TERM=xterm
PATH=/command:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
PWD=/run/s6-rc:s6-rc-init:FOaChk/servicedirs/s6rc-oneshot-runner
TZ=Europe/Paris
s6-rc: info: service foo successfully started
s6-rc: info: service legacy-services: starting
s6-rc: info: service legacy-services successfully started
```
to open a connection to the container :

```
docker exec -it 696e5177f3a9 sh
```
launching the script on a the running container returns an error :

```
/ # ./script.sh 
execlineb: fatal: unable to exec ifelse: No such file or directory
```
because at this stage you dont need with-contenv, you already have env

```
docker exec -it b1ed908f997c /bin/sh
/ # env
HOSTNAME=b1ed908f997c
SHLVL=1
HOME=/root
EMONCMS_DATADIR=/var/opt/emoncms
TERM=xterm
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
PWD=/
TZ=Europe/Paris
```
