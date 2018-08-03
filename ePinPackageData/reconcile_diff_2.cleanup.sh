#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup_package_bos.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup_package_epin.sql

if [ -f "${BATCH_FILE_PATH}/epin_package/data/${INTERFACE_FILE}" ]; then
  rm ${BATCH_FILE_PATH}/epin_package/data/${INTERFACE_FILE}
fi

