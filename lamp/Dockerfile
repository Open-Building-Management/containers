FROM ubuntu:20.04

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

RUN apt-get update;\
	apt-get install -y --no-install-recommends tzdata xz-utils;\
	apt-get install -y --no-install-recommends sed nano sudo iputils-ping net-tools;\
	apt-get install -y --no-install-recommends python3.8 python3-pip;\
	apt-get install -y --no-install-recommends ca-certificates wget

RUN mkdir $OEM_DIR;\
	groupadd $CONTAINER_USER;\
	useradd -rm -d /home/$CONTAINER_USER -s /bin/bash -g root -G sudo,dialout -u 1001 $CONTAINER_USER;\
        chown $CONTAINER_USER:$CONTAINER_USER $OEM_DIR

RUN set -eux;\
	case $TARGETPLATFORM in \
		"linux/amd64")  S6_ARCH="x86_64"  ;; \
		"linux/arm/v7") S6_ARCH="arm"  ;; \
		"linux/arm64") S6_ARCH="aarch64"  ;; \
	esac;\
	wget -P /tmp $S6_SRC/v$S6_OVERLAY_VERSION/s6-overlay-$S6_ARCH.tar.xz --no-check-certificate;\
	wget -P /tmp $S6_SRC/v$S6_OVERLAY_VERSION/s6-overlay-noarch.tar.xz --no-check-certificate;\
	tar -C / -Jxpf /tmp/s6-overlay-$S6_ARCH.tar.xz;\
	tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz

ARG PRIMOS="apache2 redis mosquitto mariadb"

RUN set -eux;\
	for i in $PRIMOS; do mkdir $S6_DIR/$i; done;\
	for i in $PRIMOS; do mkdir $S6_DIR/$i/dependencies.d; done;\
	for i in $PRIMOS; do touch $S6_DIR/$i/dependencies.d/base; done;\
	for i in $PRIMOS; do touch $S6_DIR/user/contents.d/$i; done;\
	for i in $PRIMOS; do echo "longrun" > $S6_DIR/$i/type; done;\
	for i in $PRIMOS; do echo "#!/command/execlineb -P\n" > $S6_DIR/$i/run; done;\
	echo "/usr/sbin/apache2ctl -DFOREGROUND" >> $S6_DIR/apache2/run;\
	echo "redis-server /etc/redis/redis.conf" >> $S6_DIR/redis/run;\
	echo "mysqld" >> $S6_DIR/mariadb/run;\
	echo "mosquitto -c /etc/mosquitto/mosquitto.conf" >> $S6_DIR/mosquitto/run

RUN \
	apt-get install -y --no-install-recommends --yes apache2 gettext;\
	apt-get install -y --no-install-recommends --yes mariadb-server mariadb-client;\
	apt-get install -y --no-install-recommends --yes php libapache2-mod-php php-mysql;\
	apt-get install -y --no-install-recommends --yes php-gd php-curl php-dev php-common php-mbstring;\
	apt-get install -y --no-install-recommends --yes redis-server

RUN \
	apt-get install -y git;\
	#apt-get install -y --no-install-recommends --yes mosquitto libmosquitto-dev;\
	# Compile and install mosquitto from source
	apt-get install -y build-essential make cmake openssl libssl-dev;\
	apt-get install -y libc-ares2 libc-ares-dev;\
	apt-get install -y libcjson1 libcjson-dev xsltproc docbook-xsl;\
	cd $OEM_DIR;\
	git clone https://github.com/eclipse/mosquitto \
	&& cd mosquitto \
	&& make WITH_SRV=yes \
	&& make install

ARG MQTT_CONF=/etc/mosquitto/mosquitto.conf
ARG REDIS_CONF=/etc/redis/redis.conf

RUN useradd mosquitto

RUN set -eux;\
	# apache conf
	a2enmod rewrite;\
	# mariadb conf
	service mysql start;\
	mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');";\
	mysql -e "DELETE FROM mysql.user WHERE User='';";\
	mysql -e "DROP DATABASE IF EXISTS test;";\
	mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'; FLUSH PRIVILEGES;";\
	mysql -e "CREATE DATABASE $MYSQL_DATABASE DEFAULT CHARACTER SET utf8;";\
	mysql -e "CREATE USER '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';";\
	mysql -e "GRANT ALL ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'localhost'; flush privileges;";\
	# redis conf
	sed -i "s/^save 900 1/#save 900 1/" $REDIS_CONF;\
	sed -i "s/^save 300 1/#save 300 1/" $REDIS_CONF;\
	sed -i "s/^save 60 1/#save 60 1/" $REDIS_CONF;\
	# mosquitto conf
	echo "#pid_file /var/run/mosquitto.pid" > $MQTT_CONF;\
	echo "persistence false" >> $MQTT_CONF;\
	echo "persistence_location /var/lib/mosquitto/" >> $MQTT_CONF;\
	echo "allow_anonymous false" >> $MQTT_CONF;\
	echo "listener 1883" >> $MQTT_CONF;\
	echo "password_file /etc/mosquitto/passwd" >> $MQTT_CONF;\
	echo "#log_type error" >> $MQTT_CONF;\
	touch /etc/mosquitto/passwd;\
	mosquitto_passwd -b /etc/mosquitto/passwd $MQTT_USER $MQTT_PASSWORD

RUN set -eux; \
	PHP_VER=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d"." );\
	# phpredis
	cd $OEM_DIR;\
	git clone https://github.com/phpredis/phpredis;\
	cd phpredis && phpize && ./configure && make && make install;\
	printf "extension=redis.so" | tee /etc/php/$PHP_VER/mods-available/redis.ini 1>&2;\
	phpenmod redis;\
	# redis-py
	pip3 install redis;\
	# mosquitto-php
	cd $OEM_DIR;\
	git clone https://github.com/mgdm/Mosquitto-PHP;\
	cd Mosquitto-PHP && phpize && ./configure && make && make install;\
	printf "extension=mosquitto.so" | tee /etc/php/$PHP_VER/mods-available/mosquitto.ini 1>&2;\
	phpenmod mosquitto

# revovering some space
RUN apt-get purge -y --auto-remove build-essential cmake;\
	apt-get purge -y --auto-remove libssl-dev libc-ares-dev libcjson-dev;\
	apt-get purge -y --auto-remove xsltproc docbook-xsl;\
	apt-get clean;\
	rm -rf /opt/*;\
	rm -rf /var/lib/apt/lists/*

RUN rm /var/www/html/index.html;\
	echo "<?php\n" > /var/www/html/index.php;\
	echo "phpinfo();\n" >> /var/www/html/index.php;\
	echo "?>" >> /var/www/html/index.php

EXPOSE 80
EXPOSE 1883

ENTRYPOINT ["/init"]