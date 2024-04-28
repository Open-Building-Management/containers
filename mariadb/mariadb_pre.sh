#!/command/with-contenv sh

# pre commands = prepare container for service launch
NEW_INSTALL=0

if ! [ -d "$DATADIR" ]; then
    echo "Creating data folder"
    mkdir -p "$DATADIR"
else
    #find "$DATADIR" \! -user mysql -exec chown mysql: '{}' +
    echo "Using existing data folder"
fi

if ! [ -d "$DATADIR/mysql" ]; then
    echo "Creating a new mariadb"
    mysql_install_db --user=mysql --datadir="$DATADIR/mysql" > /dev/null
    # --skip-name-resolve --skip-test-db
    NEW_INSTALL=1
else
    echo "Using existing mariadb"
fi

echo "CREATING /etc/my.cnf"
mv /etc/my.cnf /etc/my.old
echo "[mysqld]" >> /etc/my.cnf
echo "datadir=$DATADIR/mysql" >> /etc/my.cnf
