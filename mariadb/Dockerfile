ARG BUILD_FROM=alpine:3.16

FROM $BUILD_FROM

ARG \
	TARGETPLATFORM \
	S6_OVERLAY_VERSION=3.1.5.0 \
	S6_SRC=https://github.com/just-containers/s6-overlay/releases/download \
	S6_DIR=/etc/s6-overlay/s6-rc.d \
	OS_PRE=mariadb_pre \
	OS_POST=mariadb_post \
	SERVICE=mariadb

RUN mkdir -p /data;\
	apk update && apk upgrade && apk add nano make bash;\
	apk add --no-cache mariadb mariadb-client;\
	mkdir -p /run/mysqld;\
	chown -R mysql:mysql /run/mysqld

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

COPY check.sh mariadb_pre.sh mariadb_post.sh ./

RUN set -x;\
	chmod +x check.sh;\
	chmod +x mariadb_pre.sh;\
	chmod +x mariadb_post.sh

RUN set -x;\
	mkdir $S6_DIR/$OS_PRE;\
	mkdir $S6_DIR/$OS_PRE/dependencies.d;\
	touch $S6_DIR/$OS_PRE/dependencies.d/base;\
	touch $S6_DIR/user/contents.d/$OS_PRE;\
	echo "oneshot" > $S6_DIR/$OS_PRE/type;\
	echo "/mariadb_pre.sh" > $S6_DIR/$OS_PRE/up

RUN set -x;\
	mkdir $S6_DIR/$SERVICE;\
	mkdir $S6_DIR/$SERVICE/dependencies.d;\
	touch $S6_DIR/$SERVICE/dependencies.d/$OS_PRE;\
	touch $S6_DIR/user/contents.d/$SERVICE;\
	echo "longrun" > $S6_DIR/$SERVICE/type;\
	echo "#!/command/execlineb -P" > $S6_DIR/$SERVICE/run;\
	echo "s6-setuidgid mysql" >> $S6_DIR/$SERVICE/run;\
	echo "mysqld" >> $S6_DIR/$SERVICE/run

RUN set -x;\
	mkdir $S6_DIR/$OS_POST;\
	mkdir $S6_DIR/$OS_POST/dependencies.d;\
	touch $S6_DIR/$OS_POST/dependencies.d/$SERVICE;\
	touch $S6_DIR/user/contents.d/$OS_POST;\
	echo "oneshot" > $S6_DIR/$OS_POST/type;\
	echo "/mariadb_post.sh" > $S6_DIR/$OS_POST/up

ENV \
	S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
	S6_SERVICES_GRACETIME=18000 \
	TZ="Europe/Paris" \
	DATADIR=/data/emoncms

ENTRYPOINT ["/init"]
