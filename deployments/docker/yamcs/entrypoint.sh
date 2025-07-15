#!/bin/bash

pkill -9 java
rm -rf ${YAMCS_DATA_DIR}/_global.rdb/LOCK
rm -rf ${YAMCS_DATA_DIR}/nos3.rdb/LOCK

mvn ${MAVEN_HTTPS_PROXY} -Dmaven.repo.local=${MAVEN_REPO_LOCAL} -DCOMPONENT_DIR=${COMPONENT_DIR} yamcs:run

tail -f /dev/null
