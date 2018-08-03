#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

EXECUTE=prepaid_loader
INTERFACE_NAME=OfflineCampaign

TEST_CASE=(
missing_sync:1
mismatch:1
invalid_amount:1
# depricate overflow_long:1
# depricate max_long:0
invalid_not_null:1
invalid_start_code:1
invalid_negative_code:1
invalid_max_balance:1
invalid_gendoc_code:1
invalid_pocket_code:1
invalid_mobile_no:1
success:0
# depricate not_gen_package:0
dup_file_config:1
insert_adjust_CR_Y_DZ:0
insert_adjust_RS_N_ND:0
insert_adjust_CR_N_DG:0
adjust_error:0
adjust_ok_not_gen:0
adjust_ok_gen_receipt:0
adjust_ok_gen_credit_note:0
adjust_ok_not_gen_second:0
adjust_ok_gen_receipt_second:0
adjust_ok_gen_credit_note_second:0
adjust_ok_gen_credit_note_partial_receipt:0
adjust_ok_gen_credit_note_partial_mobile:0
)

# End Here

. common/execute.sh
