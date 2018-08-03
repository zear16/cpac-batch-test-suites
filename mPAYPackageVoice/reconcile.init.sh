#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init_package_mpay.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init_package_bos.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init.sql > ${WORKING_PATH}/order_id

cp ${INTERFACE_NAME}/${TEST_CASE_NAME}.file ${BATCH_FILE_PATH}/${INTERFACE_FILE}

