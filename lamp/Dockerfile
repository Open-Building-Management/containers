FROM ubuntu:20.04

ARG TARGETARCH
ARG S6_OVERLAY_VERSION=3.1.5.0
ARG S6_SRC=https://github.com/just-containers/s6-overlay/releases/download
ARG S6_DIR=/etc/s6-overlay/s6-rc.d

ENV TZ="Europe/Paris"

RUN apt-get update && apt-get install -y --no-install-recommends tzdata xz-utils

RUN apt-get install -y --no-install-recommends ca-certificates wget

RUN set -eux;\
	if [ "$TARGETARCH" = "armv7" ]; then \
            export S6_ARCH="arm"; \
        elif [ "$TARGETARCH" = "arm64" ]; then \
            export S6_ARCH="aarch64"; \
        elif [ "$TARGETARCH" = "amd64" ]; then \
            export S6_ARCH="x86_64"; \
        else \
            export S6_ARCH="$TARGETARCH"; \
        fi;\
 	wget -P /tmp $S6_SRC/v$S6_OVERLAY_VERSION/s6-overlay-$S6_ARCH.tar.xz;\
	wget -P /tmp $S6_SRC/v$S6_OVERLAY_VERSION/s6-overlay-noarch.tar.xz;\
	tar -C / -Jxpf /tmp/s6-overlay-$S6_ARCH.tar.xz;\
	tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
