#!/bin/bash

odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir

# processes
for srv in Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend gotools/client
do
    echo
    echo "### visit $srv service..."
    cd $srv
    git status
    git commit -m "update" -a
    git push
    cd -
done
