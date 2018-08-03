#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

EXECUTE=prepaid_loader
INTERFACE_NAME=mPAYPurchaseCWDC1

TEST_CASE=(
#mismatch:1
#invalid_date:1
#invalid_month:1
#invalid_day:1
#invalid_hour:1
#invalid_minute:1
#invalid_seconds:1
#invalid_not_null:1
#duplicate:1
#invalid_service_package_id:1
#invalid_content_id:1
#invalid_end_cause:1
#success_105:0
#success_186:0
#success_50001:0
#success_ins:0
# depricate service_non_bos:0
#category_not_gen:0
#end_cause_not_gen:0
#non_partial_fee:0
#gen_credit_note:0
#gen_credit_note_ins:0
#gen_cn_by_old_abbr_receipt:0
gen_cn_by_old_abbr_receipt_partial:0
gen_cn_by_old_full_receipt:0
gen_cn_by_old_full_receipt_partial:0
gen_cn_by_old_recharge:0
gen_cn_by_old_recharge_partial:0
gen_cn_by_mobile:0
reconcile_diff:0
reconcile:0
)

# End Here

. common/execute.sh
