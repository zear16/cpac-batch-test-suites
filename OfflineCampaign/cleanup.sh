#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup.sql

if [ -f "campaign/${INTERFACE_FILE}" ]; then
  rm ${BATCH_FILE_PATH}/${INTERFACE_FILE}
fi

if [ -f "${BATCH_FILE_PATH}/${INTERFACE_SYNC_FILE}" ]; then
  rm ${BATCH_FILE_PATH}/${INTERFACE_SYNC_FILE}
fi

if [ -f "${WORKING_PATH}/chk_order_id" ]; then
  CHK_ORDER_ID=$(cat ${WORKING_PATH}/chk_order_id)

  SCRIPT=${WORKING_PATH}/_cleanup.sql
  echo -e "use PMDB" > ${SCRIPT}
  echo -e "\ngo" >> ${SCRIPT}
  echo -e "\nset nocount on" >> ${SCRIPT}
  echo -e "\ndelete from PM_INF_ADJUST_BALANCE_H where ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
  echo -e "\ndelete from PM_INF_ADJUST_BALANCE_D where ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
  echo -e "\ndelete from PM_INF_ADJUST_BALANCE_B where ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
  echo -e "\ndelete from PM_INF_ADJUST_BALANCE_T where ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
  echo -e "\ndelete from PM_INF_ADJUST_BALANCE_ERROR_H where ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
  echo -e "\ndelete from PM_INF_ADJUST_BALANCE_ERROR_D where ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
  echo -e "\ndelete from PM_INF_ADJUST_BALANCE_ERROR_T where ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
  echo -e "\ndelete from PM_JOB_ORDER where ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
  echo -e "\ngo" >> ${SCRIPT}

  isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}
fi
