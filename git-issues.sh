#!/bin/bash

odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir
export PAGER=""

# processes
services="FOXDEN Authz MetaData UserMetaData DataDiscovery DataManagement DataBookkeeping Frontend SyncService SpecScansService MLHub DataHub DOIService ELogService CalibrationService ClasseInfoService gotools"
for srv in $services
do
    echo
    echo "### open github issues in $srv ..."
    cd $srv
    gh issue ls
    cd - 2>&1 1>& /dev/null
done
