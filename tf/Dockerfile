ARG BUILD_FROM=ubuntu:22.04

FROM $BUILD_FROM

ARG PYMODBUS_VERSION=3.4.1

RUN apt-get -y update;\
    apt-get -y upgrade;\
    apt-get install -y tzdata;\
    apt-get install -y wget curl nano;\
    apt-get -y install python3 python3-pip;\
    python3 -m pip install --no-cache-dir pip --upgrade;\
    python3 -m pip install --no-cache-dir pyserial pymodbus==$PYMODBUS_VERSION;\
    python3 -m pip install --no-cache-dir paho-mqtt;\
    python3 -m pip install --no-cache-dir mysql-connector-python redis;\
    python3 -m pip install --no-cache-dir click requests;\
    python3 -m pip install --no-cache-dir tflite-runtime;\
    apt-get purge -y --auto-remove python3-pip;\
    apt-get clean

COPY test.py .
