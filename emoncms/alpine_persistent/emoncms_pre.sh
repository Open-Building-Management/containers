#!/command/with-contenv sh

if ! [ -d "$EMONCMS_DATADIR" ]; then
    echo "creating timeseries folders"
    mkdir -p "$EMONCMS_DATADIR"
    mkdir -p "$EMONCMS_DATADIR/backup"
    mkdir -p "$EMONCMS_DATADIR/backup/uploads"
    for i in $TS; do mkdir -p "$EMONCMS_DATADIR/$i"; done
    chown -R "$DAEMON" "$EMONCMS_DATADIR"
else
    echo "timeseries folders : OK"
fi
