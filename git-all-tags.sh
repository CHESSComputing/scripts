#!/bin/bash

odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir

# processes
for srv in golib Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend gotools/client
do
    echo
    echo "### $srv ..."
    cd $srv
#     git tag --sort=-refname
#     git tag -l -r
    git for-each-ref --sort=creatordate --format '%(refname) %(creatordate)' refs/tags
    cd - 2>&1 1>& /dev/null
done
