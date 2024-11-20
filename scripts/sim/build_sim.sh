#!/bin/bash -i
#
# Convenience script for NOS3 development
# Use with the Dockerfile in the deployment repository
# https://github.com/nasa-itc/deployment
#

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../env.sh

# Check that local NOS3 directory exists
if [ ! -d $USER_NOS3_DIR ]; then
    echo ""
    echo "    Need to run make prep first!"
    echo ""
    exit 1
fi

# Check that configure build directory exists
if [ ! -d $USER_NOS3_BUILD_DIR/cfg ]; then
    echo ""
    echo "    Need to run make config first!"
    echo ""
    exit 1
fi

chmod g+s $BASE_DIR/sims
mkdir -p $BASE_DIR/sims/build
$DFLAGS_CPUS -v $BASE_DIR:$BASE_DIR -v $USER_NOS3_BUILD_DIR:$USER_NOS3_BUILD_DIR --name "nos_build_sim" -w $BASE_DIR $DBOX make -j$NUM_CPUS build-sim
