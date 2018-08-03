#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup.sql

if [ -f "/opt/ais/cpac/batchprepaid/ufair_bos/${INTERFACE_FILE}" ]; then
  rm /opt/ais/cpac/batchprepaid/ufair_bos/${INTERFACE_FILE}
fi

FILE_NAME=$(cat ${WORKING_PATH}/file_name)

rm /opt/ais/cpac/batchprepaid/ufair_bos/${FILE_NAME}

