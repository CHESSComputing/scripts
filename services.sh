#!/bin/bash

mkdir -p logs

# delete existing srv processes
pid=`ps auxww | grep ".*/srv$" | grep -v grep | awk '{print $2}' | awk '{print "kill -9 "$1""}'`
if [ -n "$pid" ]; then
    echo "$pid" | sed "s,\n,,g"
    echo "$pid" | sed "s,\n,,g" | /bin/sh
fi

# start new processes
for srv in Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend SyncService
services="Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend SyncService SpecScansService"
for srv in $services
do
    echo "### start $srv service..."
    cd $srv
    if [ -f server.json ]; then
        echo "$PWD/srv -config server.json"
        nohup $PWD/srv -config server.json 2>&1 1>& ../logs/$srv.log < /dev/null & \
            echo $! > ../logs/$srv.pid
    else
        echo "$PWD/srv"
        nohup $PWD/srv 2>&1 1>& ../logs/$srv.log < /dev/null & \
            echo $! > ../logs/$srv.pid
    fi
    echo "$srv started with PID=`cat ../logs/$srv.pid`"
    echo "log file: $PWD/../logs/$srv.log"
    tail -3 ../logs/$srv.log
    cd -
done
