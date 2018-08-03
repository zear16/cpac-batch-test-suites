#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

export EXECUTE=prepaid_loader
export INTERFACE_NAME=TextFileCN

TEST_CASE=(
mismatch:1
skip_first:0
invalid_not_null:1
invalid_date_format:1
invalid_day:1
invalid_month:1
invalid_number:1
invalid_number_scale:1
success:0
update_adjust:0
reconcile_diff:0
reconcile_diff_2:0
reconcile:0
)

# End Here

. common/execute.sh
