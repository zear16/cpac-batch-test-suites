#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

EXECUTE=prepaid_loader
INTERFACE_NAME=ROMReversal

TEST_CASE=(
invalid_header_field:1
header_invalid_date:1
header_invalid_day:1
header_invalid_month:1
header_invalid_not_null:1
header_missing:1
header_duplicate:1
header_invalid_effective_date:1
footer_missing:1
footer_duplicate:1
footer_invalid_amount:1
footer_invalid_count:1
invalid_detail_field:1
detail_invalid_number:1
detail_invalid_date:1
detail_invalid_day:1
detail_invalid_month:1
detail_invalid_date_format:1
detail_invalid_time:1
detail_invalid_hour:1
detail_invalid_minute:1
detail_invalid_seconds:1
detail_invalid_time_format:1
detail_invalid_not_null:1
detail_invalid_multi_load:1
# depricate detail_invalid_company:1
detail_invalid_bank:1
detail_invalid_multi_data:1
detail_invalid_branch:1
invalid_footer_field:1
success:0
invalid_mobile_no:1
gen_success:0
gen_cn_by_recharge:0
gen_cn_by_old_abbr_receipt:0
gen_cn_by_old_abbr_receipt_partial:0
gen_cn_by_old_full_receipt:0
gen_cn_by_old_full_receipt_partial:0
gen_cn_by_old_recharge:0
gen_cn_by_old_recharge_partial:0
gen_cn_by_mobile:0
detail_invalid_billing_system:1
reconcile_diff_adjust_bos:0
reconcile_diff_credit_note:0
reconcile_diff_reversal:0
reconcile_over_adjust_bos:0
reconcile_over_credit_note:0
reconcile_over_reversal:0
reconcile_not_diff:0
gen_cn_by_old_abbr_receipt_partial_fifo:0
gen_cn_by_old_abbr_receipt_partial_with_mobile:0
reconcile_partial_credit_note:0
reconcile_partial_credit_note_over:0
reconcile_partial_credit_note_missing_adjust_bos:0
)

# End Here

. common/execute.sh
