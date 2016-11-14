#!/bin/sh

# This script will add any dependencies we have to the build

# Only execute if building, not cleaning
if [ "$ACTION" == "clean" ]; then
exit 0
fi

# set -e will cause errors to propogate and cause build to fail
set -e

export SCRIPT_INPUT_FILE_0="Carthage/Build/iOS/AFNetworking.framework"
export SCRIPT_INPUT_FILE_COUNT=1

carthage copy-frameworks
