# ajout de code-server au container `tf_multiarch`

```
sudo docker build -t obm-vscode .
```

pour lancer le container, avec les sources de bios en read-only :

```
sudo docker run -it --rm -p 8080:8080 -v ./:/bios:ro -v ./user_config:/user_config obm-vscode
```


# d'autres images de code server

https://hub.docker.com/r/linuxserver/code-server
