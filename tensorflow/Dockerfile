ARG BUILD_FROM=ubuntu:22.04

FROM $BUILD_FROM

ARG \
    PYMODBUS_VERSION=3.4.1 \
    TF_WHEEL_REPO=https://github.com/PINTO0309/Tensorflow-bin/releases/download/v2.10.0 \
    TF_WHEEL_NAME=tensorflow-2.10.0-cp310-none-linux_aarch64.whl \
    PAHO_VERSION=1.6.1 \
    MYSQL_CONNECTOR_VERSION=8.0.29

RUN apt-get -y update;\
    apt-get -y upgrade;\
    apt-get install -y tzdata;\
    apt-get install -y wget curl nano;\
    apt-get -y install python3 python3-pip;\
    python3 -m pip install --no-cache-dir pip --upgrade;\
    python3 -m pip install --no-cache-dir pyserial pymodbus==$PYMODBUS_VERSION;\
    python3 -m pip install --no-cache-dir paho-mqtt==$PAHO_VERSION;\
    python3 -m pip install --no-cache-dir redis;\
    python3 -m pip install --no-cache-dir mysql-connector-python==$MYSQL_CONNECTOR_VERSION;\
    python3 -m pip install --no-cache-dir click requests;\
    wget $TF_WHEEL_REPO/$TF_WHEEL_NAME;\
    python3 -m pip install --upgrade --no-cache-dir --upgrade $TF_WHEEL_NAME;\
    rm *.whl
