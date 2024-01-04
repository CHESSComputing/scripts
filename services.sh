#!/bin/bash

mkdir -p logs

# delete existing srv processes
pid=`ps auxww | grep ".*/srv$" | grep -v grep | awk '{print $2}' | awk '{print "kill -9 "$1""}'`
if [ -n "$pid" ]; then
    echo "$pid" | sed "s,\n,,g"
    echo "$pid" | sed "s,\n,,g" | /bin/sh
fi

# start new processes
for srv in Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend
do
    echo "### start $srv service..."
    cd $srv
    if [ -f server.json ]; then
        nohup $PWD/srv -config server.json 2>&1 1>& ../logs/$srv.log < /dev/null & \
            echo $! > ../logs/$srv.pid
    else
        nohup $PWD/srv 2>&1 1>& ../logs/$srv.log < /dev/null & \
            echo $! > ../logs/$srv.pid
    fi
    echo "$srv started with PID=`cat ../logs/$srv.pid`"
    echo "log file: $PWD/../logs/$srv.log"
    tail -3 ../logs/$srv.log
    cd -
done
