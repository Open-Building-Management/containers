# FOR DEV

run the themis version of emoncms :
```
docker run --rm -p 8081:80 -p 7883:1883 --name=bios -it alexjunk/themis:alpine3.16
```
run any exe of the bios suite :
```
docker run --rm --network=container:bios -v ~/Documents/GitHub/BIOS2:/bios -it alexjunk/tf:ubuntu22.04 python3 /bios/bios.py
```
