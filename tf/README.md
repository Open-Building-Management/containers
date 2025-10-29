**tensorflow lite wheels are available via pip on aarch64, amd64 and arm/v7**

https://www.tensorflow.org/lite/guide/python

# FOR DEV

run the themis version of emoncms :
```
docker run --rm -p 8081:80 -p 7883:1883 --name=bios -it alexjunk/themis:alpine3.16
```
run any exe of the bios suite :
```
docker run --rm --network=container:bios -v ~/Documents/GitHub/BIOS2:/bios -it alexjunk/tf:ubuntu22.04 python3 /bios/bios.py
```

# changes log

full local build with all github actions inputs

```
sudo docker buildx build -t tf:multiarch_test \
  --build-arg BUILD_FROM=ubuntu:22.04 \
  --build-arg PYMODBUS_VERSION=3.11.3 \
  --build-arg PAHO_VERSION=2.1.0 \
  --build-arg NUMPY_VERSION=1.26.4 \
  --build-arg TFLITE_VERSION=2.13.0 \
  --build-arg PYFINA_VERSION=0.0.7 \
  .
```

Introducing a BUILD_FROM before the FROM instruction.

An ARG declared before the FROM instruction can’t be used after the FROM except you redeclare it after the FROM without the value.

To check if os version is fine on a running container : `cat /etc/os-release`

to specify the target os:

```
docker build -t tf:ubuntu20.04 --build-arg="BUILD_FROM=ubuntu:20.04" .
```




