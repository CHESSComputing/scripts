#!/bin/bash

odir=${CHESS_DIR:-$PWD}
echo "CHESS directory: $odir"
cd $odir

# processes
servcies="gotools Auth DataBookkeeping DataDiscovery DataManagement FOXDEN Frontend Kubernetes MLHub MetaData PublicationService SpecScansService"
for srv in $services
do
    echo
    echo "### clone $srv ..."
    git clone git@github.com:CHESSComputing/${srv}.git
done
