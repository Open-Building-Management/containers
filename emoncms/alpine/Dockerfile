FROM alpine:3.16

ARG TARGETPLATFORM
ARG S6_OVERLAY_VERSION=3.1.5.0
ARG S6_SRC=https://github.com/just-containers/s6-overlay/releases/download
ARG S6_DIR=/etc/s6-overlay/s6-rc.d

ENV TZ="Europe/Paris"

ENV CONTAINER_USER=pi
ENV MYSQL_DATABASE=emoncms
ENV MYSQL_USER=emoncms
ENV MYSQL_PASSWORD=emonpiemoncmsmysql2016
ENV OEM_DIR=/opt/openenergymonitor
ENV MQTT_USER=emonpi
ENV MQTT_PASSWORD=emonpimqtt2016

#RUN apk update && apk upgrade

# openrc is the apk package to use rc-service
RUN apk add --no-cache tzdata xz bash git;\
	apk add --no-cache sed nano sudo iputils-ping net-tools;\
	apk add --no-cache python3 py3-pip;\
	apk add --no-cache ca-certificates wget;\
	apk add --no-cache apache2 gettext;\
	apk add --no-cache mariadb mariadb-client;\
	apk add --no-cache redis;\
	apk add --no-cache mosquitto

RUN apk add --no-cache php php-apache2 php-mysqli;\
	apk add --no-cache php-gd php-curl php-common php-mbstring
	
RUN set -x;\
    PHP_VER=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1 -d".");\
	apk add --no-cache php$PHP_VER-dev

# more info on alpine-mariadb docker : https://hub.docker.com/r/yobasystems/alpine-mariadb/
# the following is not executed when installing mariadb via apk 
# cf https://mariadb.com/kb/en/mysql_install_db/
# some people say to launch /etc/init.d/mariadb setup ????
RUN mysql_install_db --user=mysql --ldata=/var/lib/mysql;\
	mkdir -p /run/mysqld;\
	chown -R mysql:mysql /run/mysqld

# it is possible to install s6-overlay with apk
#apk add --no-cache s6-overlay
RUN set -eux;\
	apk add --no-cache execline;\
	case $TARGETPLATFORM in \
		"linux/amd64")  S6_ARCH="x86_64"  ;; \
		"linux/arm/v7") S6_ARCH="arm"  ;; \
		"linux/arm64") S6_ARCH="aarch64"  ;; \
	esac;\
	wget -P /tmp $S6_SRC/v$S6_OVERLAY_VERSION/s6-overlay-$S6_ARCH.tar.xz --no-check-certificate;\
	wget -P /tmp $S6_SRC/v$S6_OVERLAY_VERSION/s6-overlay-noarch.tar.xz --no-check-certificate;\
	tar -C / -Jxpf /tmp/s6-overlay-$S6_ARCH.tar.xz;\
	tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz

ARG PRIMOS="apache2 redis mariadb"

# use bin and not command for execlineb
# cf https://github.com/just-containers/s6-overlay/issues/449
RUN set -eux;\
	for i in $PRIMOS; do mkdir $S6_DIR/$i; done;\
	for i in $PRIMOS; do mkdir $S6_DIR/$i/dependencies.d; done;\
	for i in $PRIMOS; do touch $S6_DIR/$i/dependencies.d/base; done;\
	for i in $PRIMOS; do touch $S6_DIR/user/contents.d/$i; done;\
	for i in $PRIMOS; do echo "longrun" > $S6_DIR/$i/type; done;\
	for i in $PRIMOS; do echo "#!/bin/execlineb -P" > $S6_DIR/$i/run; done;\
	echo "/usr/sbin/httpd -D FOREGROUND" >> $S6_DIR/apache2/run;\
	echo "redis-server /etc/redis.conf" >> $S6_DIR/redis/run;\
	echo "s6-setuidgid mysql" >> $S6_DIR/mariadb/run;\
	echo "mysqld" >> $S6_DIR/mariadb/run

ARG HTTP_CONF=/etc/apache2/httpd.conf
ARG MQTT_CONF=/etc/mosquitto/mosquitto.conf
ARG REDIS_CONF=/etc/redis.conf

RUN mkdir /var/www/emoncms;\
	echo "<?php" > /var/www/emoncms/index.php;\
	echo "phpinfo();" >> /var/www/emoncms/index.php;\
	echo "?>" >> /var/www/emoncms/index.php;\
	sed -i "s/^#ServerName.*/ServerName localhost/" $HTTP_CONF;\
	sed -i "s/^#LoadModule rewrite/LoadModule rewrite/" $HTTP_CONF;\
	sed -i "s/localhost\/htdocs/emoncms/g" $HTTP_CONF;\
	sed -i "/.*emoncms\">$/a \ \ \ \ DirectoryIndex index.php" $HTTP_CONF;\
	# mariadb conf
	# cf https://stackoverflow.com/questions/68578758
	apk add --no-cache openrc;\
	rc-update add mariadb;\
	mkdir -p /run/openrc; \
	touch /run/openrc/softlevel; \
	/sbin/openrc 2>/dev/unll;\
	mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');";\
	mysql -e "DELETE FROM mysql.user WHERE User='';";\
	mysql -e "DROP DATABASE IF EXISTS test;";\
	mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'; FLUSH PRIVILEGES;";\
	mysql -e "CREATE DATABASE $MYSQL_DATABASE DEFAULT CHARACTER SET utf8;";\
	mysql -e "CREATE USER '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';";\
	mysql -e "GRANT ALL ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'localhost'; flush privileges;";\
	rm -Rf /run/openrc;\
	apk del --no-cache openrc;\
	# redis conf
	sed -i "s/^save 900 1/#save 900 1/" $REDIS_CONF;\
	sed -i "s/^save 300 1/#save 300 1/" $REDIS_CONF;\
	sed -i "s/^save 60 1/#save 60 1/" $REDIS_CONF;\
	# mosquitto conf
	echo "persistence false" >> $MQTT_CONF;\
	echo "allow_anonymous false" >> $MQTT_CONF;\
	echo "listener 1883" >> $MQTT_CONF;\
	echo "password_file /etc/mosquitto/passwd" >> $MQTT_CONF;\
	echo "#log_type error" >> $MQTT_CONF;\
	touch /etc/mosquitto/passwd;\
	mosquitto_passwd -b /etc/mosquitto/passwd $MQTT_USER $MQTT_PASSWORD

EXPOSE 80

ENTRYPOINT ["/init"]