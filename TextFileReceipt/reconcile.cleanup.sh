#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup_adjust.sql

if [ -f "${BATCH_FILE_PATH}/text_file_receipt/${INTERFACE_FILE}" ]; then
  rm ${BATCH_FILE_PATH}/text_file_receipt/${INTERFACE_FILE}
fi

