#!/bin/bash

pkill -9 java
rm -rf ${YAMCS_DATA_DIR}/_global.rdb/LOCK
rm -rf ${YAMCS_DATA_DIR}/nos3.rdb/LOCK

mkdir -p /tmp/nos3
mkdir -p /tmp/nos3/data
mkdir -p /tmp/nos3/data/cam
mkdir -p /tmp/nos3/data/evs
mkdir -p /tmp/nos3/data/hk
mkdir -p /tmp/nos3/data/inst
mkdir -p /tmp/nos3/uplink

# cp $BASE_DIR/fsw/build/exe/cpu1/cf/cfe_es_startup.scr /tmp/nos3/uplink/tmp0.so
# cp $BASE_DIR/fsw/build/exe/cpu1/cf/sample.so /tmp/nos3/uplink/tmp1.so

mvn ${MAVEN_HTTPS_PROXY} -Dmaven.repo.local=${MAVEN_REPO_LOCAL} -DCOMPONENT_DIR=${COMPONENT_DIR} yamcs:run

tail -f /dev/null
