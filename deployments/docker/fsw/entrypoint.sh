#!/bin/bash

# if [ -n "${HEALTHCHECK_PORT}" ]; then

#   if (( ${HEALTHCHECK_PORT} )); then # only if port is a number proceed
#     pkill -f nc ||
#     while true; do (echo -e 'HTTP/1.1 200 OK\r\n'; echo -e "\n\tSuccess: health check port ${HEALTHCHECK_PORT}" ; echo -e "\t$(date -u +%FT%T)\n") | nc -lp ${HEALTHCHECK_PORT}; done &
#   else
#     echo "HEALTHCHECK_PORT variable is set but to a none number; therefore, not starting health check action"
#   fi

# else
#   echo "HEALTHCHECK_PORT variable is not set; therefore, not starting health check action. Optional. Proceeding"
# fi

pkill -f fsw_respawn.sh || true
pkill -f core-cpu1 || true

export LD_LIBRARY_PATH=${FSW_DIR}/cf/:${LD_LIBRARY_PATH}

mkdir -p $FSW_DIR/data
mkdir -p $FSW_DIR/data/cam
mkdir -p $FSW_DIR/data/evs
mkdir -p $FSW_DIR/data/hk
mkdir -p $FSW_DIR/data/inst
touch -p $FSW_DIR/data/dummy.txt

cd ${FSW_DIR} && \
    ./core-cpu1 -R PO 2>&1 | tee -a ${BASE_DIR}/core-cpu1.log &

tail -f /dev/null
