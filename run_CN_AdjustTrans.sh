#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

INTERFACE_NAME=CN_AdjustTrans

TEST_CASE=(
gen_success:0
wrong_number:0
)

# End Here

. common/execute.sh
