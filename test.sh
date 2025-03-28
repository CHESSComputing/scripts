#!/bin/bash

cdir=${CHESSWORK_DIR:-$PWD}
echo "CHESSWORK directory: $cdir"
cd $cdir

mkdir -p logs

# processes
services="Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend SpecScansService MLHub gotools/foxden"
for srv in $services
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
cd gotools/foxden
./test/run.sh
cd -
