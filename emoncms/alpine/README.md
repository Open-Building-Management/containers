The alpine project does not have a `sudo` group but a `wheel` group instead

To create user with sudo priviledges and access to IO through the dialout group:
```
addgroup $USER
adduser -S $USER -G wheel -u 1001
addgroup $USER dialout
```

# php-dev

php-dev is necessary to compile mosquitto-PHP and phpredis

it brings the phpize command

`apk add php-dev` not working

`apk add php8-dev` only working on alpine 3.16 not 3.17 or 3.18

# conf files customization
in the Dockerfile :

- having to use sed for the httpd.conf, but in a quite elegant way
- echo is enough for mosquitto.conf as the config file coming from the src contains only comments

# apk packages

while connected to the container in bash :

- to list installed packages `apk list -I`
- to list mosquitto related packages : `apk search mosquitto*`

in order to keep image size as small as possible, and if a package is only required at build time, in a specific RUN and is not necessary to the execution phase, this seems to be a good practise:

```
RUN apk add --no-cache package;\
    do required things;\
    apk del --no-cache package
```
the add and the del must be executed in the same RUN
