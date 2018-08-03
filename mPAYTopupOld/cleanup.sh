#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup.sql

if [ -f "${BATCH_FILE_PATH}/mPAY/${INTERFACE_FILE}" ]; then
  rm ${BATCH_FILE_PATH}/mPAY/${INTERFACE_FILE}
fi

