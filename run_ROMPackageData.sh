#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

EXECUTE=prepaid_loader
INTERFACE_NAME=ROMPackageData

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
# depricate detail_invalid_number_format:1
detail_invalid_date:1
detail_invalid_date_format:1
detail_invalid_day:1
detail_invalid_month:1
detail_invalid_time:1
detail_invalid_time_format:1
detail_invalid_hour:1
detail_invalid_minute:1
detail_invalid_seconds:1
detail_invalid_not_null:1
detail_invalid_multi_load:1
# depricate detail_invalid_company:1
detail_invalid_bank:1
package_non_data:1
# depricate package_non_topup:1
package_inactive:1
detail_invalid_multi_data:1
detail_invalid_branch:1
invalid_footer_field:1
success:0
# not use gen_success:0
reconcile_diff:0
reconcile_diff_2:0
reconcile:0
detail_invalid_billing_system:1
package_non_data_ins:1
package_inactive_ins:1
)

# End Here

. common/execute.sh
