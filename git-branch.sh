#!/bin/bash

branch=$1
odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir

# processes
services="Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend SpecScansService MLHub PublicationService DOIService gotools"
for srv in $services
do
    echo
    echo "### visit $srv service..."
    cd $srv
    if [ -n "$branch" ]; then
        git checkout $branch
    else
        git branch --show-current
    fi
    cd - 2>&1 1>& /dev/null
done
