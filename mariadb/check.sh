#!/bin/bash
# to check datadir socket and port used by mariadb
# just run ./check.sh mariadb 

_verboseHelpArgs=(
        --verbose --help
)

mysql_get_config() {
        local conf="$1"; shift
        "$@" "${_verboseHelpArgs[@]}" 2>/dev/null \
                | awk -v conf="$conf" '$1 == conf && /^[^ \t]/ { sub(/^[^ \t]+[ \t]+/, ""); print; exit }'
}

DATADIR="$(mysql_get_config 'datadir' "$@")"
SOCKET="$(mysql_get_config 'socket' "$@")"
PORT="$(mysql_get_config 'port' "$@")"

echo $DATADIR
echo $SOCKET
echo $PORT
