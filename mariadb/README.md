
To build with 2 different versions of maria
```
sudo docker build --build-arg="TARGETPLATFORM=linux/amd64" --build-arg="BUILD_FROM=alpine:3.19" -t basic_alpine3.19_maria10.11.6 .
sudo docker build --build-arg="TARGETPLATFORM=linux/amd64" --build-arg="BUILD_FROM=alpine:3.16" -t basic_alpine3.16_maria10.6.16 .
```
To run an ephemeral database :
```
docker run --rm -it basic_alpine3.16_maria10.6.16
```
To run with a database in /data/mariadb
```
docker-compose up
```

Change the image version of mariadb in compose.yaml

You can modify pre and post files as they are mounted from the host, but they must be executable.

In case they are not :

```
chmod +x mariadb_pre.sh
chmod +x mariadb_post.sh
```

Create the database, then give all the files to another user :

```
sudo chown -R root /data/mariadb
```
when lauching the container, you should see :

```
sudo docker-compose up
[+] Running 1/0
 ✔ Container mariadb-maria-1  Created                                                                                                                                                                  0.0s 
Attaching to maria-1
maria-1  | s6-rc: info: service s6rc-oneshot-runner: starting
maria-1  | s6-rc: info: service s6rc-oneshot-runner successfully started
maria-1  | s6-rc: info: service fix-attrs: starting
maria-1  | s6-rc: info: service fix-attrs successfully started
maria-1  | s6-rc: info: service legacy-cont-init: starting
maria-1  | s6-rc: info: service legacy-cont-init successfully started
maria-1  | s6-rc: info: service mariadb_pre: starting
maria-1  | Using existing data folder
maria-1  | Using existing mariadb
maria-1  | CREATING /etc/my.cnf
maria-1  | s6-rc: info: service mariadb_pre successfully started
maria-1  | s6-rc: info: service mariadb: starting
maria-1  | s6-rc: info: service mariadb successfully started
maria-1  | s6-rc: info: service mariadb_post: starting
maria-1  | 2024-04-28 14:40:25 0 [Warning] Can't create test file '/data/mariadb/mysql/e61f92c98c90.lower-test' (Errcode: 13 "Permission denied")
maria-1  | mysqld: Can't change dir to '/data/mariadb/mysql/' (Errcode: 13 "Permission denied")
maria-1  | 2024-04-28 14:40:25 0 [ERROR] Aborting
maria-1  | 2024-04-28 14:40:26 0 [Warning] Can't create test file '/data/mariadb/mysql/e61f92c98c90.lower-test' (Errcode: 13 "Permission denied")
maria-1  | mysqld: Can't change dir to '/data/mariadb/mysql/' (Errcode: 13 "Permission denied")
maria-1  | 2024-04-28 14:40:26 0 [ERROR] Aborting
maria-1  | 2024-04-28 14:40:27 0 [Warning] Can't create test file '/data/mariadb/mysql/e61f92c98c90.lower-test' (Errcode: 13 "Permission denied")
maria-1  | mysqld: Can't change dir to '/data/mariadb/mysql/' (Errcode: 13 "Permission denied")
maria-1  | 2024-04-28 14:40:27 0 [ERROR] Aborting
^CGracefully stopping... (press Ctrl+C again to force)
[+] Stopping 1/1
 ✔ Container mariadb-maria-1  Stopped                                                                                                                                                                 10.2s 
canceled
```

so uncomment line 10 of mariadb_pre.sh to give the right permission to the datadir and everything should be fine :-)


to check mariadb datadir, socket and port :
```
./check.sh mariadbd
/data/mariadb/mysql/
/run/mysqld/mysqld.sock
3306
```
to also give the right permission to the socket :
```
export SOCKET=/run/mysqld/mysqld.sock
find "${SOCKET%/*}" -maxdepth 0 \! -user mysql -exec chown mysql: '{}' \;
```

But it should not be needed as only datas are mounted from the host

more details on https://github.com/MariaDB/mariadb-docker/blob/master/11.4/docker-entrypoint.sh

https://github.com/MariaDB/mariadb-docker/issues/554

