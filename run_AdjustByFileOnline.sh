#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

EXECUTE=call_sproc
INTERFACE_NAME=AdjustByFileOnline

TEST_CASE=(
success:0
success_da:0
)

# End Here

. common/execute.sh
