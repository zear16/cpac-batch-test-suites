#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init_cfg_doc_gen.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init_old_recharge.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup_receipt.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init.sql > ${WORKING_PATH}/order_id

#cp ${INTERFACE_NAME}/${TEST_CASE_NAME}.file ${WORKING_PATH}/BOSRVS_20160616161616_001.dat
cp ${INTERFACE_NAME}/${TEST_CASE_NAME}.file ${BATCH_FILE_PATH}/ROM_RVS/${INTERFACE_FILE}

#cd ${WORKING_PATH}

#zip ${INTERFACE_FILE} BOSRVS_20160616161616_001.dat

#cd ..

#cp ${WORKING_PATH}/${INTERFACE_FILE} ${BATCH_FILE_PATH}/ROM_RVS/${INTERFACE_FILE}

