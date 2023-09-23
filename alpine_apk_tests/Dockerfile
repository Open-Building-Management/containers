ARG BUILD_FROM=alpine:3.18

FROM $BUILD_FROM

ENV \
	PHP_VER=81 \
	TZ="Europe/Paris"

RUN apk update && apk upgrade

RUN apk add --no-cache tzdata xz bash git make tar;\
	apk add --no-cache sed nano;\
	apk add --no-cache python3;\
	apk add --no-cache ca-certificates wget;\
	apk add --no-cache apache2 gettext;\
	apk add --no-cache mariadb mariadb-client;\
	apk add --no-cache redis;\
	apk add --no-cache mosquitto;\
	apk add --no-cache php php-gettext php-apache2 php-mysqli;\
	apk add --no-cache php-gd php-curl php-common php-mbstring;\
	apk add --no-cache php-session php-ctype;\
	apk add --no-cache build-base mosquitto-dev;\
	apk add --no-cache py3-pip php$PHP_VER-dev
