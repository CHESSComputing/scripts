#!/bin/bash

if [ "$#" -ne 1  ]; then
    echo "Usage: git-tag.sh <tag>"
    exit 1
fi
tag=$1
odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir

# processes
for srv in Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend gotools/client
do
    echo
    echo "### tag $srv with tag=$tag ..."
    cd $srv
    git tag --list | tail -1
    cd -
done
