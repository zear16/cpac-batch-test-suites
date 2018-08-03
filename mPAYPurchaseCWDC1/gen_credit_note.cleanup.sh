#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup_reconcile.sql

if [ -f "/dwh/nfs/DCB/DCBcwdc1google/${INTERFACE_FILE}" ]; then
  rm /dwh/nfs/DCB/DCBcwdc1google/${INTERFACE_FILE}
fi

