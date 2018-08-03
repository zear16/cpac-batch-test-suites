#!/bin/bash

SCRIPT=${WORKING_PATH}/script

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "set proc_output_params off" >> ${SCRIPT}
echo -e "set proc_return_status off" >> ${SCRIPT}
echo -e "\ndeclare @ret          int" >> ${SCRIPT}
echo -e "declare @msg          varchar(200)" >> ${SCRIPT}
echo -e "declare @receipt_id   unsigned bigint" >> ${SCRIPT}
echo -e "declare @receipt_no   varchar(35)" >> ${SCRIPT}
echo -e "declare @receipt_date date" >> ${SCRIPT}
echo -e "declare @cn_mode      char(1)" >> ${SCRIPT}
echo -e "declare @str_date     char(8)" >> ${SCRIPT}
echo -e "declare @reason_id    unsigned bigint" >> ${SCRIPT}
echo -e "\nselect @reason_id = REASON_ID from PM_CFG_BO_DOC_DETAIL where PROCESS_TYPE = 'RV'" >> ${SCRIPT}
echo -e "\nexec @ret = PM_S_SEARCH_RECEIPT_RECHARGE '20160601', '20160630'" >> ${SCRIPT}
echo -e ", '20160616', '0854000673', 3.07, null, 'unit', null" >> ${SCRIPT}
echo -e ", @receipt_id out, @receipt_no out, @receipt_date out, @cn_mode out, @msg out" >> ${SCRIPT}
echo -e "\nselect @str_date = convert(char(8), @receipt_date, 112)" >> ${SCRIPT}
echo -e "\nprint '%1!|%2!|%3!|%4!|%5!|%6!', @ret, @msg, @receipt_id, @receipt_no, @str_date, @cn_mode" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${SCRIPT} -o ${WORKING_PATH}/result
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

cat ${WORKING_PATH}/result

RESULT=$(tail -n 1 ${WORKING_PATH}/result)

echo "${RESULT}"

# Return
if [ "${RESULT}" != "0|||||" ]; then
  exit $RET_FAIL
fi

exit $RET_OK

