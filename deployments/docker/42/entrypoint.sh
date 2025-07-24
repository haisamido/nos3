#!/bin/bash

rm -f /tmp/.X1-lock || true
rm -f /tmp/.X11-unix/X1 || true

pkill -9 -f vncserver || true
pkill -9 -f Xvnc || true
pkill -9 -f websockify || true

/opt/TurboVNC/bin/vncserver -securitytypes tlsnone,x509none,none && \
  websockify -D \
    --web=/usr/share/novnc/ \
    --cert=~/novnc.pem 80 localhost:5901 
    
export DISPLAY=:${DISPLAY:-1}

DIR=/opt/nasa-itc

xterm&

rm -rf ${DIR}/42 || true
cd ${DIR} && git clone --recurse-submodules -j2 ${GIT_URL} || true && \
cd ${DIR}/ && \
  git fetch && \
  git checkout ${GIT_COMMIT} && \
  git submodule update && \
  make clean && \
  make -j2

cd ${DIR}/42 && \
  rm -rf ./InOut/{*.42,*.csv} && \
  xterm -e ./42 &
echo "Started 42 in xterm with PID $!"

tail -f /dev/null
