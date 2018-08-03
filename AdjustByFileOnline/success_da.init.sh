#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -i ${INTERFACE_NAME}/init_adjust_trans_da.sql > ${WORKING_PATH}/order_id


