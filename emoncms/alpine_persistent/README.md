# An alpine container with persistent storage

## changes with the initial alpine Dockerfile

- no more need to use emoncmsdbupdate.php in the makefile : mariadb tables initialisation is done when the first user is created.

- a oneshot s6 service called emoncms_pre to create the timeseries folders, fix permissions and run mysql_install_db if needed

- a oneshot s6 service called sql_ready initializes the emoncms database if needed and waits for mariadb to be running, before the workers can start

Using environnement variables, emoncms_pre.sh generates at startup the following conf files :
- /etc/my.cnf
- emoncms settings.ini
- config.cfg for backup module
- backup.ini PHP extension
