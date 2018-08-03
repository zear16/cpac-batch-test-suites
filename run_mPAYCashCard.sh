#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

export EXECUTE=call_sproc
export INTERFACE_NAME=mPAYCashCard

TEST_CASE=(
no_data:0
found_data_1:0
found_data_2:0
found_data_3:0
)

# End Here

. common/execute.sh

