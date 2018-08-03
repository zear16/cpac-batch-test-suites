#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup_fake_recharge.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup_reconcile.sql

if [ -f "${BATCH_FILE_PATH}/bill_topup/${INTERFACE_FILE}" ]; then
  rm ${BATCH_FILE_PATH}/bill_topup/${INTERFACE_FILE}
fi

