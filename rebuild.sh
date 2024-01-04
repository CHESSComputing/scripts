#!/bin/bash

odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir

cd golib
echo "golib library ..."
make
cd -

# processes
for srv in Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend gotools/client
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
