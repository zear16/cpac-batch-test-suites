#!/bin/bash

. common/env.sh

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i AdjustBOS/cleanup.sql

rm ${BATCH_FILE_PATH}/${INTERFACE_FILE}

if [ -f "${BATCH_FILE_PATH}/${INTERFACE_SYNC_FILE}" ]; then
  rm ${BATCH_FILE_PATH}/${INTERFACE_SYNC_FILE}
fi
