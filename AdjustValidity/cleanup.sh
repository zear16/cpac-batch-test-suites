#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup.sql

if [ -f "/opt/ais/cpac/batchprepaid/ROM/${INTERFACE_FILE}" ]; then
  rm /opt/ais/cpac/batchprepaid/ROM/${INTERFACE_FILE}
fi

