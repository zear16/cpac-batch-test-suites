#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup_old_abbr_receipt_2.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup_old_abbr_receipt_1.sql

if [ -f "${BATCH_FILE_PATH}/ROM_RVS/${INTERFACE_FILE}" ]; then
  rm ${BATCH_FILE_PATH}/ROM_RVS/${INTERFACE_FILE}
fi

