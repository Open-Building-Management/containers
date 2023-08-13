FROM alpine:3.16

ARG TARGETPLATFORM
ARG S6_OVERLAY_VERSION=3.1.5.0
ARG S6_SRC=https://github.com/just-containers/s6-overlay/releases/download
ARG S6_DIR=/etc/s6-overlay/s6-rc.d

ENV TZ="Europe/Paris"

# the sql database and the timeseries will be in /data
# we start with the sql database
# DAEMON is the user running the workers
# it must be the same as the one running the webserver
# on alpine, httpd user is apache and not www-data
ENV \
	DAEMON=apache \
	DATA=/data \
	EMONCMS_DATADIR=/var/opt/emoncms \
	TS="phpfina phpfiwa phptimeseries" \
	MYSQL_DATABASE=emoncms \
	MYSQL_USER=emoncms \
	MYSQL_PASSWORD=emonpiemoncmsmysql2016 \
	MQTT_USER=emonpi \
	MQTT_PASSWORD=emonpimqtt2016 \
	WWW=/var/www \
	OEM_DIR=/opt/openenergymonitor \
	EMONCMS_DIR=/opt/emoncms \
	EMONCMS_LOG_LOCATION=/var/log/emoncms

RUN mkdir -p $DATA

ARG \
	PRIMOS="apache2 redis mosquitto mariadb" \
	SECONDOS="emoncms_mqtt service-runner feedwriter"

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
	# initializing timeseries and mariadb with a oneshot service called emoncms_pre
	mkdir $S6_DIR/emoncms_pre;\
	mkdir $S6_DIR/emoncms_pre/dependencies.d;\
	touch $S6_DIR/emoncms_pre/dependencies.d/base;\
	echo "oneshot" > $S6_DIR/emoncms_pre/type;\
	echo "$OEM_DIR/emoncms_pre.sh" > $S6_DIR/emoncms_pre/up;\
	touch $S6_DIR/user/contents.d/emoncms_pre;\
	# starting primo services after emoncms_pre
	for i in $PRIMOS; do mkdir $S6_DIR/$i; done;\
	for i in $PRIMOS; do mkdir $S6_DIR/$i/dependencies.d; done;\
	for i in $PRIMOS; do touch $S6_DIR/$i/dependencies.d/emoncms_pre; done;\
	for i in $PRIMOS; do touch $S6_DIR/user/contents.d/$i; done;\
	for i in $PRIMOS; do echo "longrun" > $S6_DIR/$i/type; done;\
	for i in $PRIMOS; do echo "#!/command/execlineb -P" > $S6_DIR/$i/run; done;\
	echo "/usr/sbin/httpd -D FOREGROUND" >> $S6_DIR/apache2/run;\
	echo "redis-server $REDIS_CONF" >> $S6_DIR/redis/run;\
	echo "mosquitto -c $MQTT_CONF" >> $S6_DIR/mosquitto/run;\
	echo "s6-setuidgid mysql" >> $S6_DIR/mariadb/run;\
	echo "mysqld --datadir=$DATA/mysql" >> $S6_DIR/mariadb/run

# creating folders, setting permissions and cloning emoncms sources
# emoncms_pre.sh oneshot service initializes at startup timeseries folders and mariadb
RUN set -x;\
	mkdir -p $OEM_DIR;\
	mkdir -p $EMONCMS_LOG_LOCATION;\
	mkdir -p $EMONCMS_DIR;\
	chown $DAEMON $EMONCMS_LOG_LOCATION;\
	touch $EMONCMS_LOG_LOCATION/emoncms.log;\
	chmod 666 $EMONCMS_LOG_LOCATION/emoncms.log;\
	# needed for emoncms_mqtt and feedwriter which create a lock at startup
	chown $DAEMON /var/lock;\
	# needed for the backup module when importing a tar.gz
	chown $DAEMON /tmp;\
	cd $WWW && git clone -b stable https://github.com/emoncms/emoncms.git;\
	rm -Rf $WWW/emoncms/docs;\
	mkdir -p /run/mysqld;\
	chown -R mysql:mysql /run/mysqld;\
	mv /etc/my.cnf /etc/my.old;\
	echo "[mysqld]" >> /etc/my.cnf;\
	echo "datadir=$DATA/mysql" >> /etc/my.cnf 

WORKDIR $OEM_DIR

COPY makefile .
COPY emoncms_pre.sh .

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

# emoncms modules
RUN set -x;\
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
	sed -i 's/sudo //' $EMONCMS_DIR/modules/sync/emoncms-sync.sh

# redis and mosquitto conf : simple
# build-base is required to compile with gcc
# mosquitto-dev is needed to compile mosquitto-PHP
# we need phpize so we install php-dev
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
	apk del --no-cache py3-pip php$PHP_VER-dev;\
	# this will remove sources for phpredis and Mosquitto-PHP
	rm -Rf $OEM_DIR/phpredis

COPY sql_ready.sh .

# user2 level services = workers
RUN set -x;\
	# check if SQL is fully ready with a oneshot service
	mkdir $S6_DIR/sql_ready;\
	mkdir $S6_DIR/sql_ready/dependencies.d;\
	touch $S6_DIR/sql_ready/dependencies.d/legacy-services;\
	echo "oneshot" > $S6_DIR/sql_ready/type;\
	echo "$OEM_DIR/sql_ready.sh" > $S6_DIR/sql_ready/up;\
	touch $S6_DIR/user2/contents.d/sql_ready;\
	# all the long running workers start after sql_ready
	for i in $SECONDOS; do mkdir $S6_DIR/$i; done;\
	for i in $SECONDOS; do mkdir $S6_DIR/$i/dependencies.d; done;\
	for i in $SECONDOS; do touch $S6_DIR/$i/dependencies.d/sql_ready; done;\
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
	chown -R $DAEMON $EMONCMS_DIR;\
	chmod +x emoncms_pre.sh;\
	chmod +x sql_ready.sh

# this is necessary as we launch mysql_install_db at startup
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0
ENV S6_SERVICES_GRACETIME=18000

EXPOSE 80 1883

ENTRYPOINT ["/init"]
