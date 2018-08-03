#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

export EXECUTE=recharge
export INTERFACE_NAME=RechargeInterstella

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
invalid_bank:1
success:0
success_with_reward:0
missing_start_line:1
missing_end_line:1
invalid_end_line:1
threshold_error:1
threshold_ok:0
# depricate not_gen_invalid_service_channel:1
not_gen_test_number:0
not_gen_specification_id_1009001:0
not_gen_by_recharge_service:0
not_gen_missing_method:1
not_gen_missing_location:1
gen_success:0
gen_cc_out_of_range:0
gen_cc_duplicate:0
gen_cash_card:0
gen_epin_out_of_range:0
gen_epin_duplicate:0
not_gen_epin_cash_card:0
gen_epin_cash_card:0
# depricate reconcile:0
reconcile_not_gen_diff:0
reconcile_not_gen_not_diff:0
reconcile_gen_diff:0
reconcile_gen_not_diff:0
reconcile_gen_convert_diff:0
reconcile_gen_convert_not_diff:0
)

# End Here

. common/execute.sh
