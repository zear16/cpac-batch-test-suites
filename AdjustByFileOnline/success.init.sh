#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -i ${INTERFACE_NAME}/init_adjust_trans.sql > ${WORKING_PATH}/order_id


