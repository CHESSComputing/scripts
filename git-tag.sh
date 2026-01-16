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
services="Authz MetaData UserMetaData DataDiscovery DataManagement DataBookkeeping Frontend SyncService SpecScansService MLHub DataHub DOIService gotools"
for srv in $services
do
    echo
    echo "### tag $srv with tag=$tag ..."
    cd $srv
    git tag $tag
    git push --tags
    cd - 2>&1 1>& /dev/null
done
