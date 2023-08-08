# php-dev

php-dev is necessary to compile mosquitto-PHP and phpredis

it brings the phpize command

`apk add php-dev` not working

`apk add php8-dev` only working on alpine 3.16 not 3.17 or 3.18

# conf files customization

having to use sed for the httpd.conf

echo is enough for mosquitto.conf as the config file coming from the src contains only comments

# apk packages

to list installed packages while connected to the container in bash

```
apk list -I
```
