#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

EXECUTE=prepaid_loader
INTERFACE_NAME=Package

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
# depricate invalid_product:1
success:0
not_gen_package:0
gen_success:0
reconcile_diff_receipt:0
reconcile_diff_all:0
reconcile_not_diff:0
not_gen_invalid_product:0
)

# End Here

. common/execute.sh
