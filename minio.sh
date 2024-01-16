#!/bin/bash

if [ "$#" -ne 1  ]; then
    echo "Usage: minio.sh <path>"
    exit 1
fi
path=$1
odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir
mkdir -p $odir/logs

start_minio()
{
    local pid=`ps auxwww | egrep "minio server" | grep -v grep | awk 'BEGIN{ORS=" "} {print $2}'`
    if [ ! -z "${pid}" ]; then
        echo "Minio server is already running PID: $pid"
    else
        minio server $path --address :8330 2>&1 1>& $odir/logs/minio.log < /dev/null &
        echo "Minio server is started, see $odir/logs/minio.log"
    fi
}

start_minio
