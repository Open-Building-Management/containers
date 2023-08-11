# An alpine container with persistent storage

## changes with the initial alpine Dockerfile

- no more need to use emoncmsdbupdate.php in the makefile : mariadb tables initialisation is done when the first user is created. Could get rid of the makefile but I dont want to introduce more shell details in the Dockerfile

- a oneshot s6 service called emoncms_pre to create the timeseries folders and give the correct permission.

TO DO : run mysql_install_db in the oneshot service
