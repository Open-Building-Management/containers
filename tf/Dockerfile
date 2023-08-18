FROM ubuntu:22.04

RUN apt-get -y update;\
    apt-get -y upgrade;\
    apt-get install -y tzdata;\
    apt-get install -y wget curl nano;\
    apt-get -y install python3 python3-pip;\
    python3 -m pip install --no-cache-dir pip --upgrade;\
    python3 -m pip install --no-cache-dir pyserial wiringpi pymodbus;\
    python3 -m pip install --no-cache-dir paho-mqtt;\
    python3 -m pip install --no-cache-dir mysql-connector-python redis;\
    python3 -m pip install --no-cache-dir requests;\
    python3 -m pip install --no-cache-dir tflite-runtime;\
    apt-get purge -y --auto-remove python3-pip;\
    apt-get clean

COPY test.py .

CMD [ "python3", "test.py"]
