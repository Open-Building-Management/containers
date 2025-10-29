ARG BUILD_FROM=ubuntu:22.04

FROM $BUILD_FROM

ARG \
    PYMODBUS_VERSION=3.4.1 \
    PAHO_VERSION=1.6.1 \
    NUMPY_VERSION=1.26.4 \
    TFLITE_VERSION=2.13.0 \
    PYFINA_VERSION=0.0.6 \
    ENV_DIR=/ve

RUN apt-get -y update;\
    apt-get -y upgrade;\
    apt-get install -y tzdata;\
    apt-get install -y wget curl nano;\
    apt-get -y install python3 python3-pip;\
    apt-get -y install swig libjpeg-dev zlib1g-dev python3-dev python3-venv python-is-python3 unzip git cmake make;\
    python3 -m venv $ENV_DIR;\
    $ENV_DIR/bin/pip install --no-cache-dir pip --upgrade;\
    $ENV_DIR/bin/pip install --no-cache-dir pyserial pymodbus==$PYMODBUS_VERSION;\
    $ENV_DIR/bin/pip install --no-cache-dir paho-mqtt==$PAHO_VERSION;\
    $ENV_DIR/bin/pip install --no-cache-dir mysql-connector-python redis;\
    $ENV_DIR/bin/pip install --no-cache-dir click requests;\
    $ENV_DIR/bin/pip install --no-cache-dir numpy==$NUMPY_VERSION;\
    $ENV_DIR/bin/pip install --no-cache-dir tflite-runtime==$TFLITE_VERSION;\
    $ENV_DIR/bin/pip install --no-cache-dir PyFina==$PYFINA_VERSION;\
    $ENV_DIR/bin/pip install --no-cache-dir aiohttp;\
    apt-get purge -y --auto-remove swig libjpeg-dev zlib1g-dev python3-dev python-is-python3 unzip git cmake make;\
    apt-get clean

ENV \
    PATH="${ENV_DIR}/bin:$PATH" \
    TZ="Europe/Paris"
