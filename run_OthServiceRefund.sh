#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

EXECUTE=prepaid_loader
INTERFACE_NAME=OthServiceRefund

TEST_CASE=(
mismatch:1
invalid_date:1
invalid_month:1
invalid_day:1
invalid_hour:1
invalid_minute:1
invalid_seconds:1
invalid_not_null:1
duplicate:1
invalid_service_package_id:1
invalid_content_id:1
invalid_end_cause:1
success:0
# depricate service_non_bos:0
category_not_adjust:0
non_partial_fee:0
# depricate end_cause_not_adjust:0
gen_adjust:0
adjust_error:0
adjust_success:0
)

# End Here

. common/execute.sh
