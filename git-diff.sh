#!/bin/bash

odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir

# processes
services="Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend SpecScansService MLHub DOIService gotools"
for srv in $services
do
    echo
    echo "### visit $srv service..."
    cd $srv
    git diff
    cd - 2>&1 1>& /dev/null
done
