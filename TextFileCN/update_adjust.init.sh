#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init.sql > ${WORKING_PATH}/order_id

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init_adjust.sql > ${WORKING_PATH}/adjust_id

# Append Adjust ID

ADJUST_ID=$(cat ${WORKING_PATH}/adjust_id)
HEADER=$(head -n 1 ${INTERFACE_NAME}/${TEST_CASE_NAME}.file)
DATA=$(sed '2q;d' ${INTERFACE_NAME}/${TEST_CASE_NAME}.file)
DATA="${DATA}${ADJUST_ID}"

echo "${HEADER}" > ${BATCH_FILE_PATH}/${INTERFACE_FILE}
echo "${DATA}" >> ${BATCH_FILE_PATH}/${INTERFACE_FILE}

PARAM=(${DATA//|/ })
echo "${PARAM[0]}" > ${WORKING_PATH}/cn_no
echo "${PARAM[1]}" > ${WORKING_PATH}/mobile_no
echo "${PARAM[3]}" > ${WORKING_PATH}/cn_date

