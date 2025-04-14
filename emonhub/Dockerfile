ARG BUILD_FROM=alpine:3.19.1

FROM $BUILD_FROM

# paho-mqtt V2 has new API. stick to V1.x for now
ARG \
    SRC=https://github.com/openenergymonitor/emonhub \
    BRANCH=stable \
    PYMODBUS_VERSION=3.4.1 \
    PAHO_VERSION=1.6.1 \
    EMONHUB_ENV=/opt/v \
    EMONHUB_DIR=/opt/openenergymonitor \
    TEMP_DIR=/opt/temp

RUN set -eux;\
    mkdir $EMONHUB_DIR \
    mkdir $TEMP_DIR

RUN set -eux;\
    apk update && apk upgrade;\
    apk add git tzdata nano python3 py3-pip py3-virtualenv py3-setuptools;\
    #BlueZ libraries and header files
    apk add bluez bluez-dev;\
    # spi headers in package linux-headers :-)
    # cf https://pkgs.alpinelinux.org/contents?file=*spi*&path=&name=linux-headers&branch=edge
    apk add linux-headers;\
    # gcc
    apk add build-base;\
    # python distutils
    apk add python3-dev;\
    python3 -m venv $EMONHUB_ENV;\
    $EMONHUB_ENV/bin/pip install --no-cache-dir configobj;\
    #$EMONHUB_ENV/bin/pip install --no-cache-dir RPi.GPIO;\
    $EMONHUB_ENV/bin/pip install --no-cache-dir pymodbus==$PYMODBUS_VERSION;\
    $EMONHUB_ENV/bin/pip install --no-cache-dir --upgrade paho-mqtt==$PAHO_VERSION;\
    $EMONHUB_ENV/bin/pip install --no-cache-dir requests py-sds011 sdm_modbus minimalmodbus;\
    $EMONHUB_ENV/bin/pip install --no-cache-dir spidev;\
    cd $TEMP_DIR;\
    # to install spidev, another option is :
    # git clone https://github.com/doceme/py-spidev
    # cd py-spidev;\
    # python3 setup.py install;\
    # installing pybluez through pip is not working
    #$EMONHUB_ENV/bin/pip install --no-cache-dir pybluez;\
    git clone https://github.com/pybluez/pybluez;\
    cd pybluez;\
    $EMONHUB_ENV/bin/python3 setup.py install;\
    # Custom rpi-rfm69 library used for SPI RFM69 Low Power Labs interfacer
    $EMONHUB_ENV/bin/pip install https://github.com/openenergymonitor/rpi-rfm69/archive/refs/tags/v0.3.0-oem-4.zip;\
    # recover some space
    apk del --no-cache build-base python3-dev bluez-dev;\
    rm -Rf $TEMP_DIR

RUN set -eux;\
    cd $EMONHUB_DIR;\
    git clone -b $BRANCH $SRC

ENV \
    PATH="${EMONHUB_ENV}/bin:$PATH" \
    TZ="Europe/Paris"

