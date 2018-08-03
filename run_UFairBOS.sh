#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

EXECUTE=prepaid_loader
INTERFACE_NAME=UFairBOS

TEST_CASE=(
missing_sync:1
mismatch:1
invalid_amount:1
invalid_not_null:1
invalid_date_format:1
invalid_day:1
invalid_month:1
invalid_hour:1
invalid_minute:1
invalid_seconds:1
invalid_valid_dtm:1
success:0
# depricate invalid_mobile_no:1
# depricate overflow_long:1
# depricate max_long:0
dup_file_config:1
insert_adjust:0
adjust_error:0
adjust_ok:0
adjust_pos_gen_receipt:0
adjust_pos_gen_credit_note:0
adjust_neg_gen_receipt:0
adjust_neg_gen_credit_note:0
adjust_pos_gen_credit_note_partial_receipt:0
adjust_pos_gen_credit_note_partial_mobile:0
)

# End Here

. common/execute.sh
