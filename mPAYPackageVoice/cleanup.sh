#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup_package_mpay.sql

if [ -f "${BATCH_FILE_PATH}/mPAY_PKG_VOICE/${INTERFACE_FILE}" ]; then
  rm ${BATCH_FILE_PATH}/mPAY_PKG_VOICE/${INTERFACE_FILE}
fi

