#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

export EXECUTE=call_sproc
export INTERFACE_NAME=ConvertPostToPre

TEST_CASE=(
order_not_ready:0
order_mismatch_mobile_no:0
order_normal_bos:0
order_normal_rtbs:0
order_normal_excess_bos:0
order_normal_excess_rtbs:0
reconcile_diff_credit_note:0
reconcile_diff_receipt:0
reconcile_not_diff:0
)

# End Here

. common/execute.sh

