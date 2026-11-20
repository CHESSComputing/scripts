#!/usr/bin/env bash
set -euo pipefail
ref=main
repo=https://github.com/CHESSComputing
services="Authz MetaData UserMetaData DataDiscovery DataManagement DataBookkeeping Frontend SyncService SpecScansService MLHub DataHub DOIService ELogService CalibrationService ClasseInfoService"
for srv in $services
do
  if [ -f ./golib/bin/gendocs ]; then
    ./golib/bin/gendocs -ref $ref -repo $repo/$srv -root $srv -service $srv -out "$srv/docs/ENDPOINTS.md"
  fi
done
