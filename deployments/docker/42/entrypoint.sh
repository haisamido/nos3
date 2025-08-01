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
    
export DISPLAY=${DISPLAY:-:1}
export DIR=/opt/nasa-itc
export GIT_FOLDER=${GIT_FOLDER}

xterm &

rm -rf /opt/nasa-itc/42/NO3InOut/{*.42,*.csv} 

if [ "$RECOMPILE" == "true" ]; then
  cd /opt/nasa-itc/42 && \
    git fetch && \
    git checkout ${GIT_COMMIT} && \
    git pull origin && \
    git submodule update && \
    make clean && \
    make -j2
fi

STARTUP_FOLDER=${STARTUP_FOLDER:-NO3InOut}

cd /opt/nasa-itc/42 && \
  xterm -e "./42 ${STARTUP_FOLDER}" &

echo "Started 42 with PID $!"

tail -f /dev/null
