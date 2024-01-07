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
for srv in golib Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend gotools/client
do
    echo
    echo "### visit $srv service..."
    echo "--- git commit -m \"$msg\" -a"
    cd $srv
    git status
    git commit -m "$msg" -a
    git push
    cd - 2>&1 1>& /dev/null
done
