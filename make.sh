#!/bin/bash

cdir=${CHESSWORK_DIR:-$PWD}
echo "CHESSWORK directory: $cdir"
cd $cdir

mkdir -p logs

# processes
services="Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend SpecScansService MLHub PublicationService DOIService gotools/foxden gotools/migrate gotools/transform"
for srv in $services
do
    echo
    echo "### $srv service..."
    cd $srv
    make
    code=$?
    if [ $code -ne 0 ]; then
        exit $code
    fi
    cd - 2>&1 1>& /dev/null
done
