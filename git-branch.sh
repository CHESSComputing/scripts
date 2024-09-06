#!/bin/bash

if [ "$#" -ne 1  ]; then
    echo "Usage: git-branch.sh <branch>"
    exit 1
fi
branch=$1
odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir

# processes
services="Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend SpecScansService MLHub PublicationService gotools"
for srv in $services
do
    echo
    echo "### visit $srv service..."
    cd $srv
    git checkout $branch
    cd - 2>&1 1>& /dev/null
done
