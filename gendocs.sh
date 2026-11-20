#!/usr/bin/env bash
set -euo pipefail
ref=main
repo=https://github.com/CHESSComputing
services="Authz MetaData UserMetaData DataDiscovery DataManagement DataBookkeeping Frontend SyncService SpecScansService MLHub DataHub DOIService ELogService CalibrationService ClasseInfoService"
for srv in $services
do
  echo ""
  cd $srv
  make docs
  cd - 2>&1 1>& /dev/null
done
