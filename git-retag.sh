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
    git tag -d ${tag} && git push origin :refs/tags/${tag} && git tag $tag
    git push --tags
    cd -
done
