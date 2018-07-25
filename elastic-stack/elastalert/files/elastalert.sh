#!/bin/bash

PIDFILE=/var/run/elastalert.pid

start () {
    /usr/local/bin/elastalert --config /etc/elastalert/config.yaml 2>&1 &
    echo $! > $PIDFILE
    echo "Elastalert is starting"
}

stop () {
    if [ -e $PIDFILE ]
    then
        /bin/pkill -F $PIDFILE
        rm $PIDFILE
        echo "Stopping Elastalert"
    else
        echo 'Elastalert is not running'
    fi
}

reload () {
    if [ -e $PIDFILE ]
    then
        /bin/pkill -SIGHUP -F $PIDFILE
        echo "Elastalert reloaded"
    else
        echo 'Elastalert is not running'
    fi
}

case $1 in
    start)
        start
        ;;
    stop)
        stop
        ;;
    reload)
        reload
        ;;
    restart)
        stop
        sleep 1
        start
        ;;
    *) exit 1
esac
