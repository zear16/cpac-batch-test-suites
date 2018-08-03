#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

export EXECUTE=prepaid_loader
export INTERFACE_NAME=AdjustINS

TEST_CASE=(
missing_sync:1
mismatch:1
invalid_number:1
overflow_long:1
max_long:0
invalid_date:1
invalid_month:1
invalid_day:1
invalid_hour:1
invalid_minute:1
invalid_seconds:1
invalid_not_null:1
invalid_company:1
success:0
reconcile_adj_trans_diff:0
reconcile_adj_trans_diff_google:0
reconcile_adj_trans_diff_adjust:0
reconcile_adj_bos_diff_date:0
reconcile_adj_diff_receipt:0
reconcile_adj_diff_dcb:0
reconcile_adj_diff_all:0
reconcile:0
missing_start_line:1
missing_end_line:1
invalid_end_line:1
)

# End Here

. common/execute.sh
