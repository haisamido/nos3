# This example toolchain file describes the cross compiler to use for
# the target architecture indicated in the configuration file.

# Basic cross system configuration
SET(CMAKE_SYSTEM_NAME           Linux)
SET(CMAKE_SYSTEM_VERSION        1)
SET(CMAKE_SYSTEM_PROCESSOR      amd64)

# Specify the cross compiler executables
# Typically these would be installed in a home directory or somewhere
# in /opt.  However in this example the system compiler is used.
SET(CMAKE_C_COMPILER            "/usr/bin/gcc")
SET(CMAKE_CXX_COMPILER          "/usr/bin/g++")

# Configure the find commands
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM   NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY   NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE   NEVER)

# These variable settings are specific to cFE/OSAL and determines which 
# abstraction layers are built when using this toolchain
SET(CFE_SYSTEM_PSPNAME      "nos-linux")
SET(OSAL_SYSTEM_OSTYPE      "nos")

#SET(CMAKE_C_FLAGS_INIT "" CACHE STRING "C Flags required by platform")
#SET(CMAKE_SHARED_LINKER_FLAGS "-pg")

# Build Specific
add_definitions(-DBYTE_ORDER_LE)
add_definitions(-D_LINUX_OS_)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(CI_TRANSPORT udp_tf)
set(TO_TRANSPORT udp_tf) # Note udp_tf used for Transfer Frames required for CryptoLib
