#!/usr/bin/bash -ie

clear
make stop clean prep config
make
cp /opt/neo/etc/settings.xml ~/.nos3/yamcs/
make stop launch
sleep 144
make stop
