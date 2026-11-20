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
services="Authz MetaData UserMetaData DataDiscovery DataManagement DataBookkeeping Frontend SyncService SpecScansService MLHub DataHub DOIService ELogService CalibrationService ClasseInfoService gotools"
for srv in $services
do
  echo
  echo "### visit $srv service and apply tag=$tag..."
  (
    cd "$srv" || exit 1
    git tag $tag
    git -c core.sshCommand="ssh -o IdentitiesOnly=yes -o ControlMaster=no -o ControlPath=none -F ~/.ssh/config" push --tags
  )
done
