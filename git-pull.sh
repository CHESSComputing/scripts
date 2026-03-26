#!/bin/bash

odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir

# processes
services="golib Authz MetaData UserMetaData DataDiscovery DataManagement DataBookkeeping Frontend SyncService SpecScansService MLHub DataHub DOIService ClasseInfoService gotools"
for srv in $services
do
    echo
    echo "### visit $srv service..."
    echo "--- git pull"
    cd $srv
    if [ -f go.mod ]; then
      git checkout -- go.mod
    fi
    git pull
    cd - 2>&1 1>& /dev/null
done

# pull out FOXDEN configs
cd FOXDEN
git pull
cd -
