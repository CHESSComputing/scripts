#!/bin/bash

cdir=${CHESSWORK_DIR:-$PWD}
echo "CHESSWORK directory: $cdir"
cd $cdir

# processes
services="Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend SyncService SpecScansService MLHub DataHub gotools/foxden"
for srv in $services
do
    echo
    echo "### $srv service..."
    cd $srv
    gh release list | grep -v Draft | head -1
    code=$?
    if [ $code -ne 0 ]; then
        exit $code
    fi
    cd - 2>&1 1>& /dev/null
done
