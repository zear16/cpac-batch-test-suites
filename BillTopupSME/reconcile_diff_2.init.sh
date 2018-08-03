#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup_recharge.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init_fake_recharge.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init.sql > ${WORKING_PATH}/order_id

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init_reconcile.sql > ${WORKING_PATH}/reconcile_order_id

cp ${INTERFACE_NAME}/${TEST_CASE_NAME}.file ${BATCH_FILE_PATH}/bill_topup/${INTERFACE_FILE}


