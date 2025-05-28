#!/bin/bash

# Find the PID of SampleSimDeployment
PID=$(pgrep -f SampleSimDeployment)

# Check if PID was found
if [ -z "$PID" ]; then
    echo "❌ SampleSimDeployment process not found."
    exit 1
fi

echo "✅ Found SampleSimDeployment with PID: $PID"

# Attach GDB to the process
gdb -q -p "$PID"
