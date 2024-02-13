#!/bin/bash

cdir=${CHESSWORK_DIR:-$PWD}
echo "CHESSWORK directory: $cdir"
cd $cdir

# processes
services="Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend SpecScansService MLHub PublicationService"
for srv in $services
do
    echo
    echo "### $srv service..."
    cd $srv
    PAGER="" gh run list --workflow release.yml --limit 1
    code=$?
    if [ $code -ne 0 ]; then
        exit $code
    fi
    cd - 2>&1 1>& /dev/null
done
