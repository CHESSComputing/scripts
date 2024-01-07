#!/bin/bash

odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir

# processes
for srv in golib Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend gotools/client
do
    echo
    echo "### visit $srv service..."
    cd $srv
    git push
    cd - 2>&1 1>& /dev/null
done
