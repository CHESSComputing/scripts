#!/bin/bash

odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir

# processes
services="Authz MetaData UserMetaData DataDiscovery DataManagement DataBookkeeping Frontend SyncService SpecScansService MLHub DataHub DOIService ELogService CalibrationService gotools"
for srv in $services; do
  echo
  echo "### visit $srv service..."
  (
    cd "$srv" || exit 1
    git -c core.sshCommand="ssh -o IdentitiesOnly=yes -o ControlMaster=no -o ControlPath=none -F ~/.ssh/config" push
  )
done
