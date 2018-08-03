#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init.sql > ${WORKING_PATH}/order_id

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init_proc.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init_language.sql

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/init_cfg_doc_gen.sql

