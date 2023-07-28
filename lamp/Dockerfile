FROM ubuntu:20.04

ARG TARGETARCH
ARG S6_OVERLAY_VERSION=3.1.5.0
ARG S6_SRC=https://github.com/just-containers/s6-overlay/releases/download
ARG S6_DIR=/etc/s6-overlay/s6-rc.d

ENV TZ="Europe/Paris"

RUN apt-get update && apt-get install -y --no-install-recommends tzdata xz-utils

RUN apt-get install -y --no-install-recommends ca-certificates wget

RUN set -eux;\
	case $TARGETARCH in \
    		"amd64")  S6_ARCH="x86_64"  ;; \
    		"arm/v7") S6_ARCH="arm"  ;; \
		"arm64") S6_ARCH="aarch64"  ;; \
	esac;\
 	wget -P /tmp $S6_SRC/v$S6_OVERLAY_VERSION/s6-overlay-$S6_ARCH.tar.xz;\
	wget -P /tmp $S6_SRC/v$S6_OVERLAY_VERSION/s6-overlay-noarch.tar.xz;\
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
        echo "mysqld" >> $S6_DIR/mariadb/run

RUN \
        apt-get install -y --no-install-recommends --yes apache2; \
        apt-get install -y --no-install-recommends --yes mariadb-server mariadb-client; \
        apt-get install -y --no-install-recommends --yes redis-server

RUN \
        apt-get install -y git;\
        #apt-get install -y --no-install-recommends --yes mosquitto libmosquitto-dev;\
        # Compile and install mosquitto
        apt-get install -y build-essential make cmake openssl libssl-dev;\
        apt-get install -y libc-ares2 libc-ares-dev; \
        apt-get install -y libcjson1 libcjson-dev xsltproc docbook-xsl; \
        git clone https://github.com/eclipse/mosquitto \
        && cd mosquitto \
        && make WITH_SRV=yes \
        && make install

ENV mqtt_user=emonpi
ENV mqtt_password=emonpimqtt2016

ARG mqttconf=/etc/mosquitto/mosquitto.conf

RUN useradd mosquitto

RUN set -eux;\
        echo "mosquitto -c /etc/mosquitto/mosquitto.conf" >> $S6_DIR/mosquitto/run;\
        echo "#pid_file /var/run/mosquitto.pid" > $mqttconf;\
        echo "persistence false" >> $mqttconf;\
        echo "persistence_location /var/lib/mosquitto/" >> $mqttconf;\
        echo "#log_dest file /var/log/mosquitto/mosquitto.log" >> $mqttconf;\
        echo "allow_anonymous false" >> $mqttconf;\
        echo "listener 1883" >> $mqttconf;\
        echo "password_file /etc/mosquitto/passwd" >> $mqttconf;\
        echo "#log_type error" >> $mqttconf;\
        touch /etc/mosquitto/passwd; \
        mosquitto_passwd -b /etc/mosquitto/passwd $mqtt_user $mqtt_password

EXPOSE 80
EXPOSE 1883

ENTRYPOINT ["/init"]
