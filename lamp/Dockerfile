FROM ubuntu:20.04

ARG TARGETARCH
ARG S6_OVERLAY_VERSION=3.1.5.0
ARG S6_DIR=/etc/s6-overlay/s6-rc.d
ARG S6_SRC=https://github.com/just-containers/s6-overlay/releases/download

ENV TZ="Europe/Paris"

RUN apt-get update && apt-get install -y --no-install-recommends tzdata xz-utils curl

RUN set -eux;\
  if [ "$TARGETARCH" = "arm/v7" ]; then \
    export S6_ARCH="arm"; \
  elif [ "$TARGETARCH" = "arm64" ]; then \
    export S6_ARCH="aarch64"; \
  elif [ "$TARGETARCH" = "amd64" ]; then \
    export S6_ARCH="x86_64"; \
  else \
    export S6_ARCH="$TARGETARCH"; \
  fi;\
  cd /tmp;\
  curl -L -f -s $S6_SRC/v$S6_OVERLAY_VERSION/s6-overlay-noarch.tar.xz;\
  tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz;\
  curl -L -f -s $S6_SRC/v$S6_OVERLAY_VERSION/s6-overlay-$S6_ARCH.tar.xz;\
  tar -C / -Jxpf /tmp/s6-overlay-$S6_ARCH.tar.xz
