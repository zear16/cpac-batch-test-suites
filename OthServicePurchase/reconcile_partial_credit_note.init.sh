#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init_old_abbr_receipt_1.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init_partial.sql > ${WORKING_PATH}/order_id

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init_reconcile_partial.sql > ${WORKING_PATH}/reconcile_order_id

SCRIPT=${WORKING_PATH}/script
echo -e "use PMDB

go

set nocount on

declare @data_date char(8)
declare @backward  int

select @backward = convert(int,FIELD1_VALUE)
from PM_SYSTEM_ATTRIBUTE_DTL
where ATTRIBUTE_CODE = 'CPAC_PARAM'
and DB_VALUE = 'QUERY_RECHARGE_PERIOD'

select @data_date = convert(char(8), dateadd(mm, -@backward, getdate()), 112)

print '%1!', @data_date

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/data_date

PATTERN="\[\[DATA_DATE\]\]"
DATA_DATE=$(cat ${WORKING_PATH}/data_date)
CONTENT=$(cat ${INTERFACE_NAME}/${TEST_CASE_NAME}.template)

echo "${CONTENT//$PATTERN/$DATA_DATE}" > ${INTERFACE_NAME}/${TEST_CASE_NAME}.file

cp ${INTERFACE_NAME}/${TEST_CASE_NAME}.file ${BATCH_FILE_PATH}/${INTERFACE_FILE}

