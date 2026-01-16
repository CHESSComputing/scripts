#!/bin/bash

odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir

# processes
services="Authz MetaData UserMetaData DataDiscovery DataManagement DataBookkeeping Frontend SyncService SpecScansService MLHub DataHub DOIService"

# add all gotools subdirectories dynamically
for tool in gotools/*; do
    [ -d "$tool" ] && services="$services $tool"
done

for srv in $services
do
    echo
    echo "### visit $srv service..."
    cd "$srv" || { echo "Cannot enter $srv"; continue; }
    if [ ! -f go.mod ]; then
      echo "No go.mod found in $srv, skipping..."
      cd - >/dev/null 2>&1
      continue
    fi
    rm go.mod go.sum
    go mod init github.com/CHESSComputing/$srv
    go mod tidy
    echo >> go.mod
    # determine correct relative path to golib
    if [[ "$srv" == gotools/* ]]; then
        echo "replace github.com/CHESSComputing/golib => ../../golib" >> go.mod
    else
        echo "replace github.com/CHESSComputing/golib => ../golib" >> go.mod
    fi
    git status
    cd - 2>&1 1>& /dev/null
done
