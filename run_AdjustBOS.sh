#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

export EXECUTE=prepaid_loader
export INTERFACE_NAME=AdjustBOS

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
duplicate_data:1
duplicate_same_file:1
success:0
reconcile_adj_trans_diff:0
reconcile_adj_trans_diff_google:0
reconcile_adj_trans_diff_adjust:0
reconcile_adj_bos_diff_date:0
reconcile_adj_diff_receipt:0
reconcile_adj_diff_dcb:0
reconcile_adj_diff_all:0
reconcile:0
)

# End Here

. common/execute.sh
