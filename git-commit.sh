#!/bin/bash

odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir

msg=$1
if [ "$msg" == "" ]; then
    msg="update"
fi

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
    cd -
done
