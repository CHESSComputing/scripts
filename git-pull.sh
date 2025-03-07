#!/bin/bash

odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir

# processes
services="golib Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend SpecScansService MLHub PublicationService DOIService gotools/foxden gotools/migrate gotools/transform"
for srv in $services
do
    echo
    echo "### visit $srv service..."
    echo "--- git pull"
    cd $srv
    git checkout -- go.mod
    git pull
    cd - 2>&1 1>& /dev/null
done

# pull out FOXDEN configs
cd FOXDEN
git pull
cd -
