FROM alpine:3.16

ARG TARGETPLATFORM
ARG S6_OVERLAY_VERSION=3.1.5.0
ARG S6_SRC=https://github.com/just-containers/s6-overlay/releases/download
ARG S6_DIR=/etc/s6-overlay/s6-rc.d

ENV TZ="Europe/Paris"

# DAEMON is the user running the workers
# it must be the same as the one running the webserver
# on alpine, httpd user is apache and not www-data
ENV DAEMON=apache
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
ARG SECONDOS="emoncms_mqtt service-runner feedwriter"
ARG TS="phpfina phpfiwa phptimeseries"
ARG HTTP_CONF=/etc/apache2/httpd.conf
ARG MQTT_CONF=/etc/mosquitto/mosquitto.conf
ARG REDIS_CONF=/etc/redis.conf
# we could do PHP_VER=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1 -d".") in each RUN
# we need PHP_VER to install the php-dev apk package and for the path to PHP CONF/INI files
ARG PHP_VER=8
# we dont modify php.ini, we create new extensions in conf.d
ARG PHP_CONF=/etc/php8/conf.d
# source for Mosquitto-PHP extension
# original repo is https://github.com/mgdm/Mosquitto-PHP
# but it does not work for php8
ARG MOSQUITTO_PHP=https://github.com/openenergymonitor/Mosquitto-PHP

RUN apk update && apk upgrade

RUN apk add --no-cache tzdata xz bash git make;\
	apk add --no-cache sed nano;\
	apk add --no-cache python3;\
	apk add --no-cache ca-certificates wget;\
	apk add --no-cache apache2 gettext;\
	apk add --no-cache mariadb mariadb-client;\
	apk add --no-cache redis;\
	apk add --no-cache mosquitto

# php-gettext available via apk 
RUN apk add --no-cache php php-gettext php-apache2 php-mysqli;\
	apk add --no-cache php-gd php-curl php-common php-mbstring;\
	apk add --no-cache php-session php-ctype

# more info on alpine-mariadb docker : https://hub.docker.com/r/yobasystems/alpine-mariadb/
# the following is not executed when installing mariadb via apk 
# cf https://mariadb.com/kb/en/mysql_install_db/
# some people say to launch /etc/init.d/mariadb setup ????
RUN mysql_install_db --user=mysql --ldata=/var/lib/mysql;\
	mkdir -p /run/mysqld;\
	chown -R mysql:mysql /run/mysqld

# it is possible to install s6-overlay with apk but it does not provide user2
#RUN apk add --no-cache s6-overlay
# if using the s6-overlays tarballs & execlineb is missing : apk add --no-cache execline
RUN set -x;\
	case $TARGETPLATFORM in \
		"linux/amd64")  S6_ARCH="x86_64"  ;; \
		"linux/arm/v7") S6_ARCH="arm"  ;; \
		"linux/arm64") S6_ARCH="aarch64"  ;; \
	esac;\
	wget -P /tmp $S6_SRC/v$S6_OVERLAY_VERSION/s6-overlay-$S6_ARCH.tar.xz --no-check-certificate;\
	wget -P /tmp $S6_SRC/v$S6_OVERLAY_VERSION/s6-overlay-noarch.tar.xz --no-check-certificate;\
	tar -C / -Jxpf /tmp/s6-overlay-$S6_ARCH.tar.xz;\
	tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz

# if s6-overlay is installed via apk, use bin and not command for execlineb !!
# cf https://github.com/just-containers/s6-overlay/issues/449
RUN set -x;\
	for i in $PRIMOS; do mkdir $S6_DIR/$i; done;\
	for i in $PRIMOS; do mkdir $S6_DIR/$i/dependencies.d; done;\
	for i in $PRIMOS; do touch $S6_DIR/$i/dependencies.d/base; done;\
	for i in $PRIMOS; do touch $S6_DIR/user/contents.d/$i; done;\
	for i in $PRIMOS; do echo "longrun" > $S6_DIR/$i/type; done;\
	for i in $PRIMOS; do echo "#!/command/execlineb -P" > $S6_DIR/$i/run; done;\
	echo "/usr/sbin/httpd -D FOREGROUND" >> $S6_DIR/apache2/run;\
	echo "redis-server $REDIS_CONF" >> $S6_DIR/redis/run;\
	echo "s6-setuidgid mysql" >> $S6_DIR/mariadb/run;\
	echo "mysqld" >> $S6_DIR/mariadb/run;\
	echo "mosquitto -c $MQTT_CONF" >> $S6_DIR/mosquitto/run

# creating folders, setting permissions and cloning emoncms sources
RUN set -x;\
	mkdir -p $OEM_DIR;\
	mkdir -p $EMONCMS_LOG_LOCATION;\
	mkdir -p $EMONCMS_DIR;\
	mkdir -p $EMONCMS_DATADIR;\
	mkdir -p $EMONCMS_DATADIR/backup;\
	mkdir -p $EMONCMS_DATADIR/backup/uploads;\
	for i in $TS; do mkdir -p $EMONCMS_DATADIR/$i; done;\
	chown -R $DAEMON $EMONCMS_DATADIR;\
	chown $DAEMON $EMONCMS_LOG_LOCATION;\
	touch $EMONCMS_LOG_LOCATION/emoncms.log;\
	chmod 666 $EMONCMS_LOG_LOCATION/emoncms.log;\
	# needed for emoncms_mqtt and feedwriter which create a lock at startup
	chown $DAEMON /var/lock;\
	# needed for the backup module when importing a tar.gz
	chown $DAEMON /tmp;\
	cd $WWW && git clone -b stable https://github.com/emoncms/emoncms.git;\
	rm -Rf $WWW/emoncms/docs

WORKDIR $OEM_DIR

COPY makefile .

# apache2/emoncms conf
RUN set -x;\
	# the following 3 lines are for the admin module : not nice ;-(
	# in container the admin module is just to see emoncms log
	# solution could be not to use admin module anymore
	# for this set enable_admin_ui to false
	git config --system --replace-all safe.directory '*';\
	git clone https://github.com/openenergymonitor/EmonScripts;\
	cp EmonScripts/install/emonsd.config.ini EmonScripts/install/config.ini;\
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
# we remove it at the end of the run but it is a small package
RUN set -x;\
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
	make module name=graph;\
	make module name=dashboard;\
	make symodule name=sync;\
	make symodule name=postprocess;\
	make symodule name=backup;\
	# backup and sync configuration
	echo "user=$DAEMON" > config.cfg;\
	echo "backup_script_location=$EMONCMS_DIR/modules/backup" >> config.cfg;\
	echo "emoncms_location=$WWW/emoncms" >> config.cfg;\
	echo "backup_location=$EMONCMS_DATADIR/backup" >> config.cfg;\
	echo "database_path=$EMONCMS_DATADIR" >> config.cfg;\
	echo "emonhub_config_path=" >> config.cfg;\
	echo "emonhub_specimen_config=" >> config.cfg;\
	echo "backup_source_path=$EMONCMS_DATADIR/backup/uploads" >> config.cfg;\ 
	cp config.cfg $EMONCMS_DIR/modules/backup/config.cfg;\
	echo "post_max_size=3G" > $PHP_CONF/backup.ini;\
	echo "upload_max_filesize=3G" >> $PHP_CONF/backup.ini;\
	echo "upload_tmp_dir=$EMONCMS_DATADIR/backup/uploads" >> $PHP_CONF/backup.ini;\
	# removing all trailing sudo instructions in Trystan shell scripts....
	sed -i 's/sudo //' $EMONCMS_DIR/modules/backup/emoncms-import.sh;\
	sed -i 's/sudo //' $EMONCMS_DIR/modules/backup/emoncms-export.sh;\
	sed -i 's/sudo //' $EMONCMS_DIR/modules/sync/emoncms-sync.sh;\
	# recovering some space
	apk del --no-cache openrc;\
	rm -Rf /run/openrc

# redis and mosquitto conf : simple
# build-base is required to compile with gcc
# mosquitto-dev is needed to compile mosquitto-PHP
RUN set -x;\
	apk add --no-cache build-base mosquitto-dev;\
	apk add --no-cache py3-pip php$PHP_VER-dev;\
	sed -i "s/^save 900 1/#save 900 1/" $REDIS_CONF;\
	sed -i "s/^save 300 1/#save 300 1/" $REDIS_CONF;\
	sed -i "s/^save 60 1/#save 60 1/" $REDIS_CONF;\
	git clone https://github.com/phpredis/phpredis;\
	cd phpredis && phpize && ./configure && make && make install;\
	printf "extension=redis.so" | tee $PHP_CONF/redis.ini 1>&2;\
	pip3 install redis;\
	echo "persistence false" >> $MQTT_CONF;\
	echo "allow_anonymous false" >> $MQTT_CONF;\
	echo "listener 1883" >> $MQTT_CONF;\
	echo "password_file /etc/mosquitto/passwd" >> $MQTT_CONF;\
	echo "#log_type error" >> $MQTT_CONF;\
	touch /etc/mosquitto/passwd;\
	mosquitto_passwd -b /etc/mosquitto/passwd $MQTT_USER $MQTT_PASSWORD;\
	git clone $MOSQUITTO_PHP;\
	cd Mosquitto-PHP && phpize && ./configure && make && make install;\
	printf "extension=mosquitto.so" | tee $PHP_CONF/mosquitto.ini 1>&2;\
	apk del --no-cache build-base mosquitto-dev;\
	apk del --no-cache py3-pip php$PHP_VER-dev

# user2 level services = workers
RUN set -x;\
	for i in $SECONDOS; do mkdir $S6_DIR/$i; done;\
	for i in $SECONDOS; do mkdir $S6_DIR/$i/dependencies.d; done;\
	for i in $SECONDOS; do touch $S6_DIR/$i/dependencies.d/legacy-services; done;\
	for i in $SECONDOS; do touch $S6_DIR/user2/contents.d/$i; done;\
	for i in $SECONDOS; do echo "longrun" > $S6_DIR/$i/type; done;\
	for i in $SECONDOS; do echo "#!/command/execlineb -P" > $S6_DIR/$i/run; done;\
	echo "s6-setuidgid $DAEMON" >> $S6_DIR/emoncms_mqtt/run;\
	echo "php $WWW/emoncms/scripts/services/emoncms_mqtt/emoncms_mqtt.php" >> $S6_DIR/emoncms_mqtt/run;\
	echo "s6-setuidgid $DAEMON" >> $S6_DIR/service-runner/run;\
	echo "python3 $WWW/emoncms/scripts/services/service-runner/service-runner.py" >> $S6_DIR/service-runner/run;\
	echo "s6-setuidgid $DAEMON" >> $S6_DIR/feedwriter/run;\
	echo "php $WWW/emoncms/scripts/feedwriter.php" >> $S6_DIR/feedwriter/run;\
	#chown $DAEMON $OEM_DIR;\
	chown -R $DAEMON $WWW/emoncms;\
	chown -R $DAEMON $EMONCMS_DIR

EXPOSE 80
EXPOSE 1883

ENTRYPOINT ["/init"]
