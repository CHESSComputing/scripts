#!/bin/bash

if [ "$#" -ne 1  ]; then
    echo "Usage: git-commit.sh <msg>"
    exit 1
fi
msg=$1
odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir

# processes
services="Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend SpecScansService MLHub PublicationService gotools/foxden gotools/migrate gotools/transform"
for srv in $services
do
    echo
    echo "### visit $srv service..."
    echo "--- git commit -m \"$msg\" -a"
    cd $srv
    git commit -m "$msg" -a
    cd - 2>&1 1>& /dev/null
done
