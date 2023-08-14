FROM alpine:3.16

ARG TARGETPLATFORM
ARG S6_OVERLAY_VERSION=3.1.5.0
ARG S6_SRC=https://github.com/just-containers/s6-overlay/releases/download
ARG S6_DIR=/etc/s6-overlay/s6-rc.d

ENV TZ="Europe/Paris"

ENV EMONCMS_DATADIR=/var/opt/emoncms

RUN apk update && apk upgrade && apk add nano make

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

ARG ONE_SHOT=foo

COPY script.sh .

COPY makefile .

# making a one shot service named foo
RUN set -x;\
	mkdir $S6_DIR/$ONE_SHOT;\
	mkdir $S6_DIR/$ONE_SHOT/dependencies.d;\
	touch $S6_DIR/$ONE_SHOT/dependencies.d/base;\
	echo "oneshot" > $S6_DIR/$ONE_SHOT/type;\
	echo "/script.sh" > $S6_DIR/$ONE_SHOT/up;\
	touch $S6_DIR/user/contents.d/$ONE_SHOT;\
	chmod +x script.sh;\
	make test

ENTRYPOINT ["/init"]
