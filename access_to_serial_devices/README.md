# good to know

On a pi, bluetooth is `/dev/ttyAMA0`, so if you want to use emonPi or RFM69Pi cards attached to the gpio, you will have to disable bluetooth if running an SD card written with the following HA process :

https://www.home-assistant.io/installation/raspberrypi#writing-the-image-with-balena-etcher

Disabling bluetooth requires an ssh superuser connection, that you can establish like detailed here :

https://developers.home-assistant.io/docs/operating-system/debugging/

once you are connected with `ssh root@homeassistant.local -p 22222`, edit the `/mnt/boot/config.txt` and add the following lines at the end :

```
[all]
dtoverlay=disable-bt
```

# on the web

https://www.losant.com/blog/how-to-access-serial-devices-in-docker

https://stackoverflow.com/questions/24225647/docker-a-way-to-give-access-to-a-host-usb-or-serial-device

http://marc.merlins.org/perso/linux/post_2018-12-20_Accessing-USB-Devices-In-Docker-_ttyUSB0_-dev-bus-usb-_-for-fastboot_-adb_-without-using-privileged.html

of course you can use the privileged docker option....

# add a udev rule to make serial devices readable by non-root users
```
sudo nano /etc/udev/rules.d/999-serial.rules
```
and add the following rules :
```
KERNEL=="ttyUSB[0-19]*",MODE="0666"
KERNEL=="ttyAMA[0-9]*",MODE="0666"
```
if you want to run a docker image named emonhub with access to the serial, just do :
```
sudo docker run --rm --device-cgroup-rule='c 204:* rmw' --device-cgroup-rule='c 188:* rmw' -v $(pwd):/bios -v /dev:/dev -it emonhub sh
```
we assume you have got some scripts in the current folder, you want to mount them in the container as /bios

to check the major numbers of our devices  : 
```
ls -al /dev/ttyAMA*
crw-rw-rw- 1 root dialout 204, 64 Oct  7 15:30 /dev/ttyAMA0
ls -al /dev/ttyUSB*
crw-rw-rw- 1 root dialout 188, 0 Oct  7 15:57 /dev/ttyUSB0
```
cf https://www.kernel.org/doc/Documentation/admin-guide/devices.txt

https://www.kernel.org/doc/Documentation/cgroup-v1/devices.txt

# use the device option

previously, we add rules for ttyUSB and ttyAMA, but only ttyUSB are ephemeral (can be plugged and unplugged at any time).

ttyAMA devices are permanently attached, so you can utilize the docker device option :
```
sudo docker run --rm -v $(pwd):/bios --device=/dev/ttyAMA0 -it emonhub sh
```
# publish datas on the broker host

this is not a real use case, but if you want to publish datas read through serial on a broker running on the host :
```
sudo docker run --rm --network host -v $(pwd):/bios --device=/dev/ttyAMA0 -it emonhub sh
```
# about capabilities

not of any use here but worth mentionning

https://stackoverflow.com/questions/30905674/newer-versions-of-docker-have-cap-add-what-caps-can-be-added

https://man7.org/linux/man-pages/man7/capabilities.7.html
