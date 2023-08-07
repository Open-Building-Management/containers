FROM alpine:3.16

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
ENV WWW=/var/www
ENV EMONCMS_DATADIR=/var/opt/emoncms
ENV EMONCMS_DIR=/opt/emoncms
ENV EMONCMS_LOG_LOCATION=/var/log/emoncms

ARG PRIMOS="apache2 redis mariadb mosquitto"
ARG SECONDOS="emoncms_mqtt"
ARG TS="phpfina phpfiwa phptimeseries"
ARG HTTP_CONF=/etc/apache2/httpd.conf
ARG MQTT_CONF=/etc/mosquitto/mosquitto.conf
ARG REDIS_CONF=/etc/redis.conf

#RUN apk update && apk upgrade

# build-base is required to compile with gcc
# mosquitto-dev is needed to compile mosquitto-PHP
RUN apk add --no-cache tzdata xz bash git make build-base;\
	apk add --no-cache sed nano sudo;\
	apk add --no-cache python3 py3-pip;\
	apk add --no-cache ca-certificates wget;\
	apk add --no-cache apache2 gettext;\
	apk add --no-cache mariadb mariadb-client;\
	apk add --no-cache redis;\
	apk add --no-cache mosquitto mosquitto-dev

# php-gettext available via apk 
RUN apk add --no-cache php php-gettext php-apache2 php-mysqli;\
	apk add --no-cache php-gd php-curl php-common php-mbstring;\
	apk add --no-cache php-session php-ctype
	
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
# so we can drop the TARGETPLATFORM GLOBAL ARG which supposes to have buildx
# in case we switch back to the manual s6-overlay install, we have to apk add --no-cache execline
RUN apk add --no-cache s6-overlay

# use bin and not command for execlineb
# cf https://github.com/just-containers/s6-overlay/issues/449
RUN set -x;\
	for i in $PRIMOS; do mkdir $S6_DIR/$i; done;\
	for i in $PRIMOS; do mkdir $S6_DIR/$i/dependencies.d; done;\
	for i in $PRIMOS; do touch $S6_DIR/$i/dependencies.d/base; done;\
	for i in $PRIMOS; do touch $S6_DIR/user/contents.d/$i; done;\
	for i in $PRIMOS; do echo "longrun" > $S6_DIR/$i/type; done;\
	for i in $PRIMOS; do echo "#!/bin/execlineb -P" > $S6_DIR/$i/run; done;\
	echo "/usr/sbin/httpd -D FOREGROUND" >> $S6_DIR/apache2/run;\
	echo "redis-server $REDIS_CONF" >> $S6_DIR/redis/run;\
	echo "s6-setuidgid mysql" >> $S6_DIR/mariadb/run;\
	echo "mysqld" >> $S6_DIR/mariadb/run;\
	echo "mosquitto -c $MQTT_CONF" >> $S6_DIR/mosquitto/run

# apache2/emoncms conf
# no sudo group on alpine, using the wheel group instead
# httpd user is apache and not www-data
RUN set -x;\ 
	addgroup $CONTAINER_USER;\
	adduser -S $CONTAINER_USER -G wheel dialout -u 1001;\
	mkdir -p $OEM_DIR;\
	mkdir -p $EMONCMS_LOG_LOCATION;\
	mkdir -p $EMONCMS_DIR;\
	for i in $TS; do mkdir -p $EMONCMS_DATADIR/$i; done;\
	for i in $TS; do chown apache:root $EMONCMS_DATADIR/$i; done;\
        chown $CONTAINER_USER:$CONTAINER_USER $OEM_DIR;\
	chown $CONTAINER_USER $WWW;\	
	chown $CONTAINER_USER $EMONCMS_LOG_LOCATION;\
	touch $EMONCMS_LOG_LOCATION/emoncms.log;\
	chmod 666 $EMONCMS_LOG_LOCATION/emoncms.log;\
	chown $CONTAINER_USER $EMONCMS_DIR;\
	cd $WWW && git clone -b stable https://github.com/emoncms/emoncms.git;\
	cd $OEM_DIR;\
	echo "emoncms_dir = '$EMONCMS_DIR'" > settings.ini;\
	echo "openenergymonitor_dir = '$OEM_DIR'" >> settings.ini;\
	echo "[sql]" >> settings.ini;\
	echo "server = 'localhost'" >> settings.ini;\
	echo "database = '$MYSQL_DATABASE'" >> settings.ini;\
	echo "username = '$MYSQL_USER'" >> settings.ini;\
	echo "password = '$MYSQL_PASSWORD'" >> settings.ini;\
	echo "dbtest   = true" >> settings.ini;\
	echo "[redis]" >> settings.ini;\
	echo "enabled = true" >> settings.ini;\
	echo "prefix = ''" >> settings.ini;\
	echo "[mqtt]" >> settings.ini;\
	echo "enabled = true" >> settings.ini;\
	echo "user = '$MQTT_USER'" >> settings.ini;\
	echo "password = '$MQTT_PASSWORD'" >> settings.ini;\
	echo "[feed]" >> settings.ini;\
	echo "engines_hidden = [0,6,10]" >> settings.ini;\
	echo "redisbuffer[enabled] = true" >> settings.ini;\
	echo "redisbuffer[sleep] = 300" >> settings.ini;\
	echo "phpfina[datadir] = '$EMONCMS_DATADIR/phpfina/'" >> settings.ini;\
	echo "phptimeseries[datadir] = '$EMONCMS_DATADIR/phptimeseries/'" >> settings.ini;\
	echo "[interface]" >> settings.ini;\
	echo "enable_admin_ui = true" >> settings.ini;\
	echo "feedviewpath = 'graph/'" >> settings.ini;\
	echo "favicon = 'favicon_emonpi.png'" >> settings.ini;\
	echo "[log]" >> settings.ini;\
	echo "; Log Level: 1=INFO, 2=WARN, 3=ERROR" >> settings.ini;\
	echo "level = 2" >> settings.ini;\
	cp settings.ini $WWW/emoncms/settings.ini;\
	sed -i 's/^#ServerName.*/ServerName localhost/' $HTTP_CONF;\
	sed -i '/LoadModule rewrite_module/s/^#//g' $HTTP_CONF;\
	#sed -i 's/^#LoadModule rewrite/LoadModule rewrite/' $HTTP_CONF;\
	# delete between 2 patterns with sed
	# https://techstop.github.io/delete-lines-strings-between-two-patterns-sed/
	sed -i '/<Directory "\/var\/www\/localhost\/htdocs\">/,/<\/Directory>/d' $HTTP_CONF;\
	sed -i 's/localhost\/htdocs/emoncms/g' $HTTP_CONF;\
	echo "<Directory $WWW/emoncms>" >> $HTTP_CONF;\
	echo "    Options FollowSymLinks" >> $HTTP_CONF;\
	echo "    AllowOverride All" >> $HTTP_CONF;\
	echo "    DirectoryIndex index.php" >> $HTTP_CONF;\
	echo "    Require all granted" >> $HTTP_CONF;\
	echo "</Directory>" >> $HTTP_CONF

# mariadb conf
# cf https://stackoverflow.com/questions/68578758
# openrc is the apk package to use rc-service
# to remove openrc : apk del --no-cache openrc
# and rm -Rf /run/openrc
RUN apk add --no-cache openrc;\
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
	apk del --no-cache openrc;\
	rm -Rf /run/openrc

# redis conf : simple
RUN sed -i "s/^save 900 1/#save 900 1/" $REDIS_CONF;\
	sed -i "s/^save 300 1/#save 300 1/" $REDIS_CONF;\
	sed -i "s/^save 60 1/#save 60 1/" $REDIS_CONF;\
	PHP_VER=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1 -d".");\
	cd $OEM_DIR;\
	git clone https://github.com/phpredis/phpredis;\
	cd phpredis && phpize && ./configure && make && make install;\
	printf "extension=redis.so" | tee /etc/php$PHP_VER/conf.d/redis.ini 1>&2;\
	pip3 install redis

# mosquitto conf : fine
RUN echo "persistence false" >> $MQTT_CONF;\
	echo "allow_anonymous false" >> $MQTT_CONF;\
	echo "listener 1883" >> $MQTT_CONF;\
	echo "password_file /etc/mosquitto/passwd" >> $MQTT_CONF;\
	echo "#log_type error" >> $MQTT_CONF;\
	touch /etc/mosquitto/passwd;\
	mosquitto_passwd -b /etc/mosquitto/passwd $MQTT_USER $MQTT_PASSWORD;\
	PHP_VER=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1 -d".");\
	cd $OEM_DIR;\
	git clone https://github.com/openenergymonitor/Mosquitto-PHP;\
	cd Mosquitto-PHP && phpize && ./configure && make && make install;\
	printf "extension=mosquitto.so" | tee /etc/php$PHP_VER/conf.d/mosquitto.ini 1>&2

RUN set -x;\
	mkdir -p $S6_DIR/user2;\
	mkdir -p $S6_DIR/user2/contents.d;\
	touch $S6_DIR/user2/type;\
	echo "bundle" > $S6_DIR/user2/type;\
	for i in $SECONDOS; do mkdir $S6_DIR/$i; done;\
	for i in $SECONDOS; do mkdir $S6_DIR/$i/dependencies.d; done;\
	for i in $SECONDOS; do touch $S6_DIR/$i/dependencies.d/legacy-services; done;\
	for i in $SECONDOS; do touch $S6_DIR/user2/contents.d/$i; done;\
	for i in $SECONDOS; do echo "longrun" > $S6_DIR/$i/type; done;\
	for i in $SECONDOS; do echo "#!/bin/execlineb -P" > $S6_DIR/$i/run; done;\
	echo "s6-setuidgid $CONTAINER_USER" >> $S6_DIR/emoncms_mqtt/run;\
	echo "php $WWW/emoncms/scripts/services/emoncms_mqtt/emoncms_mqtt.php" >> $S6_DIR/emoncms_mqtt/run

EXPOSE 80
EXPOSE 1883

ENTRYPOINT ["/init"]
