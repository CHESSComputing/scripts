#!/bin/bash

odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir

# processes
for srv in Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend gotools/client
do
    echo
    echo "### visit $srv service..."
    cd $srv
    rm go.mod go.sum
    go mod init github.com/CHESSComputing/$srv
    go mod tidy
    echo >> go.mod
    if [ "$srv" == "gotools/client" ]; then
        echo "replace github.com/CHESSComputing/golib => ../../golib" >> go.mod
    else
        echo "replace github.com/CHESSComputing/golib => ../golib" >> go.mod
    fi
    git status
    cd -
done
