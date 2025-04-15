build localy with all the details :

```
sudo docker build --progress=plain -t emonhubtest --build-arg="BUILD_FROM=alpine:3.20" --build-arg="PYMODBUS_VERSION=3.6.8" .
```

to check the pip ackages once connected :
```
/opt/v/bin/pip list
```

to run with an emoncms container named bios2-themis:

```
sudo docker run --rm -it --device=/dev/ttyAMA0 --network=container:bios2-themis-1 emonhub sh
```

https://raw.githubusercontent.com/openenergymonitor/emonhub/master/conf/emonhub.conf


# setuptools on venv

it seems that for alpine 3.20 and higher, setuptools is not installed on the venv

it is rational as everything should be done through pip

so, to install spidev with setuptools :
```
cd $TEMP_DIR;\
$EMONHUB_ENV/bin/pip install --no-cache-dir setuptools;\
git clone https://github.com/doceme/py-spidev;\
cd py-spidev;\
python3 setup.py install;\
```
same for pybluez but not sure it is used in emonhub interfacers
```
# installing pybluez through pip is not working
$EMONHUB_ENV/bin/pip install --no-cache-dir pybluez;\
git clone https://github.com/pybluez/pybluez;\
cd pybluez;\
$EMONHUB_ENV/bin/python3 setup.py install;\
```
it seems it is more bluepy that is needed by the bluetooth interfacer

https://github.com/IanHarvey/bluepy

to be installed through pip, bluepy needs the glib and glib-dev apk packages
