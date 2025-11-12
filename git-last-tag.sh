#!/bin/bash

odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir

# processes
services="Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend SyncService SpecScansService MLHub DataHub DOIService gotools"
for srv in $services
do
    echo
    echo "### $srv ..."
    cd $srv
    git describe --tags --abbrev=0
#     git for-each-ref --sort=creatordate --format '%(refname) %(creatordate)' refs/tags | tail -1
    cd - 2>&1 1>& /dev/null
done
