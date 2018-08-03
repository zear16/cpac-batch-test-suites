#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

export EXECUTE=call_sproc
export INTERFACE_NAME=PluginCN

TEST_CASE=(
load_success:0
)

# End Here

. common/execute.sh

