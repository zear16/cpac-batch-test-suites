#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init_fake_recharge.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init.sql > ${WORKING_PATH}/order_id

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init_reconcile.sql > ${WORKING_PATH}/reconcile_order_id

cp ${INTERFACE_NAME}/${TEST_CASE_NAME}.file ${BATCH_FILE_PATH}/ROMBOS201606163G_001.dat
#cp ${INTERFACE_NAME}/${TEST_CASE_NAME}.file ${WORKING_PATH}/ROMBOS201606163G_001.dat

#cd ${WORKING_PATH}

#zip ${INTERFACE_FILE} ROMBOS201606163G_001.dat

#cd ..

#cp ${WORKING_PATH}/${INTERFACE_FILE} ${BATCH_FILE_PATH}/ROM/${INTERFACE_FILE}

