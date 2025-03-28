#!/bin/bash

odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir

cd golib
echo "golib library ..."
make
cd -

# processes
services="Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend SpecScansService MLHub gotools/foxden gotools/migrate gotools/transform"
for srv in $services
do
    echo "### visit $srv service..."
    cd $srv
    echo "run: go get -u ."
    go get -u
    echo "run: make"
    make
    code=$?
    if [ $code -ne 0 ]; then
        exit $code
    fi
    cd -
done
