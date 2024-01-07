#!/bin/bash

cdir=${CHESSWORK_DIR:-$PWD}
echo "CHESSWORK directory: $cdir"
cd $cdir

mkdir -p logs


# processes
for srv in golib Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend gotools/client
do
    echo
    echo "### $srv service..."
    cd $srv
    make test
    code=$?
    if [ $code -ne 0 ]; then
        exit $code
    fi
    cd -
done

echo
echo "Integration tests"
cd gotools/client
./test/run.sh
cd -
