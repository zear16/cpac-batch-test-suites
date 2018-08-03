#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup_service.sql

if [ -f "${BATCH_FILE_PATH}/${INTERFACE_SYNC_FILE}" ]; then
  rm ${BATCH_FILE_PATH}/${INTERFACE_SYNC_FILE}
fi
