FROM alexjunk/lamp

ENV WWW=/var/www
ENV EMONCMS_DATADIR=/var/opt/emoncms
ENV EMONCMS_DIR=/opt/emoncms
ENV EMONCMS_LOG_LOCATION=/var/log/emoncms

WORKDIR $OEM_DIR

RUN wget https://raw.githubusercontent.com/Open-Building-Management/containers/main/makefile --no-check-certificate

# for backup module quiet install
RUN git clone https://github.com/openenergymonitor/EmonScripts; \
	cp EmonScripts/install/emonsd.config.ini EmonScripts/install/config.ini

ARG TS="phpfina phpfiwa phptimeseries"

RUN chown $CONTAINER_USER $WWW;\
	mkdir -p $EMONCMS_LOG_LOCATION;\
	chown $CONTAINER_USER $EMONCMS_LOG_LOCATION;\
	touch $EMONCMS_LOG_LOCATION/emoncms.log;\
	chmod 666 $EMONCMS_LOG_LOCATION/emoncms.log;\
	for i in $TS; do mkdir -p $EMONCMS_DATADIR/$i; done;\
	for i in $TS; do chown www-data:root $EMONCMS_DATADIR/$i; done;\
	mkdir -p $EMONCMS_DIR;\
	chown $CONTAINER_USER $EMONCMS_DIR

#for sync to run...
RUN sudo_file=/etc/sudoers.d/$CONTAINER_USER;\
	echo $CONTAINER_USER' ALL=(ALL) NOPASSWD: ALL' | tee $sudo_file;\
	chmod 0440 $sudo_file

RUN set -eux;\
	cd $WWW && git clone -b stable https://github.com/emoncms/emoncms.git;\
	cd $OEM_DIR;\
	echo "emoncms_dir = '$EMONCMS_DIR'\n" > settings.ini;\
	echo "openenergymonitor_dir = '$OEM_DIR'\n\n" >> settings.ini;\
	echo "[sql]\n" >> settings.ini;\
	echo "server = '127.0.0.1'\n" >> settings.ini;\
	echo "database = '$MYSQL_DATABASE'\n" >> settings.ini;\
	echo "username = '$MYSQL_USER'\n" >> settings.ini;\
	echo "password = '$MYSQL_PASSWORD'\n" >> settings.ini;\
	echo "dbtest   = true\n\n" >> settings.ini;\
	echo "[redis]\n" >> settings.ini;\
	echo "enabled = true\n" >> settings.ini;\
	echo "prefix = ''\n\n" >> settings.ini;\
	echo "[mqtt]\n" >> settings.ini;\
	echo "enabled = true\n" >> settings.ini;\
	echo "user = '$MQTT_USER'\n" >> settings.ini;\
	echo "password = '$MQTT_PASSWORD'\n\n" >> settings.ini;\
	echo "[feed]\n" >> settings.ini;\
	echo "engines_hidden = [0,6,10]\n" >> settings.ini;\
	echo "redisbuffer[enabled] = true\n" >> settings.ini;\
	echo "redisbuffer[sleep] = 300\n" >> settings.ini;\
	echo "phpfina[datadir] = '$EMONCMS_DATADIR/phpfina/'\n" >> settings.ini;\
	echo "phptimeseries[datadir] = '$EMONCMS_DATADIR/phptimeseries/'\n\n" >> settings.ini;\
	echo "[interface]\n" >> settings.ini;\
	echo "enable_admin_ui = true\n" >> settings.ini;\
	echo "feedviewpath = 'graph/'\n" >> settings.ini;\
	echo "favicon = 'favicon_emonpi.png'\n\n" >> settings.ini;\
	echo "[log]\n" >> settings.ini;\
	echo "; Log Level: 1=INFO, 2=WARN, 3=ERROR\n" >> settings.ini;\
	echo "level = 2\n" >> settings.ini;\
	cp settings.ini $WWW/emoncms/settings.ini;\
	######################################################################################
	echo "ServerName localhost\n\n" > emonsd.conf;\
	echo "ErrorLog $EMONCMS_LOG_LOCATION/apache2-error.log\n" >> emonsd.conf;\
	sudo cp emonsd.conf /etc/apache2/conf-available/emonsd.conf;\
	sudo a2enconf emonsd.conf;\
	######################################################################################
	echo "<VirtualHost *:80>\n" > emoncms.conf;\
	echo "    ServerName localhost\n" >> emoncms.conf;\
	echo "    ServerAdmin webmaster@localhost\n" >> emoncms.conf;\
	echo "    DocumentRoot $WWW/emoncms\n\n" >> emoncms.conf;\
	echo "    ErrorLog $EMONCMS_LOG_LOCATION/apache2-error.log\n\n" >> emoncms.conf;\
	echo "    <Directory $WWW/emoncms>\n" >> emoncms.conf;\
	echo "        Options FollowSymLinks\n" >> emoncms.conf;\
	echo "        AllowOverride All\n" >> emoncms.conf;\
	echo "        DirectoryIndex index.php\n" >> emoncms.conf;\
	echo "        Require all granted\n" >> emoncms.conf;\
	echo "    </Directory>\n" >> emoncms.conf;\
	echo "</VirtualHost>\n" >> emoncms.conf;\
	sudo cp emoncms.conf /etc/apache2/sites-available/emoncms.conf;\
	sudo a2dissite 000-default.conf;\
	sudo a2ensite emoncms

RUN sudo service mysql start; \
	make module name=graph; \
	make module name=dashboard; \
	make symodule name=sync; \
	make symodule name=postprocess; \
	make symodule name=backup
