#!/bin/bash

odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir

# processes
services="Authz MetaData DataDiscovery DataManagement DataBookkeeping Frontend SpecScansService MLHub PublicationService gotools/client"
for srv in $services
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
    cd - 2>&1 1>& /dev/null
done
