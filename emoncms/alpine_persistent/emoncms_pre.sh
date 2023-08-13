#!/command/with-contenv sh

NEW_INSTALL=false

if ! [ -d "$EMONCMS_DATADIR" ]; then
    echo "Creating timeseries folders"
    mkdir -p "$EMONCMS_DATADIR"
    mkdir -p "$EMONCMS_DATADIR/backup"
    mkdir -p "$EMONCMS_DATADIR/backup/uploads"
    for i in $TS; do mkdir -p "$EMONCMS_DATADIR/$i"; done
    chown -R "$DAEMON" "$EMONCMS_DATADIR"
    
else
    echo "Using existing timeseries"
fi

if ! [ -d "$DATA/mysql" ]; then
    echo "Creating a new mariadb"
    mysql_install_db --user=mysql --datadir=$DATA/mysql --skip-name-resolve --skip-test-db > /dev/null;\
    NEW_INSTALL=true
else
    echo "Using existing mariadb"
fi

printf "$NEW_INSTALL" > /var/run/s6/container_environment/NEW_INSTALL
