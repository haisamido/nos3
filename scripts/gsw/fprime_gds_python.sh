#!/bin/bash -i
#
# Convenience script for NOS3 development
# Use with the Dockerfile in the deployment repository
# https://github.com/nasa-itc/deployment
#

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../env.sh

cd $SCRIPT_DIR/../fsw/fprime/fprime-nos3
# sleep(20)
python3 fprime_gds_Yamcs_script.py --tts-addr ${URLIP_FPRIME}

