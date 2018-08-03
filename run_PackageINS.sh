#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

EXECUTE=prepaid_loader
INTERFACE_NAME=PackageINS

TEST_CASE=(
#missing_sync:1
#mismatch:1
#invalid_number:1
#overflow_long:1
#max_long:0
#invalid_date:1
#invalid_month:1
#invalid_day:1
#invalid_hour:1
#invalid_minute:1
#invalid_seconds:1
#invalid_not_null:1
#invalid_company:1
#invalid_product:1
success:0
#missing_start_line:1
#missing_end_line:1
#invalid_end_line:1
not_gen_package:0
gen_success:0
)

# End Here

. common/execute.sh
