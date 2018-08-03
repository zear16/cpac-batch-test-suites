#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

EXECUTE=prepaid_loader
INTERFACE_NAME=AdjustValidity

TEST_CASE=(
#header_mismatch:1
#header_invalid_code:1
#request_date_null:1
#header_invalid_date:1
#header_invalid_date_format:1
#header_success:0
#detail_mismatch:1
#detail_invalid_code:1
#mobile_no_null:1
#detail_success:0
#footer_mismatch:1
#footer_invalid_code:1
#count_record_null:1
#invalid_count_record:1
#footer_succes:0
#count_record_mismatch:1
#success:0
#forward:0
#dup_file_config:1
insert_adjust:0
adjust_error:0
adjust_ok:0
)

# End Here

. common/execute.sh
