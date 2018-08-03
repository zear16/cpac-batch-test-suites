#!/bin/bash

SCRIPT=${WORKING_PATH}/script

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "select 'RECHARGE' as SOURCE_TYPE, R2.RECHARGE_ID as ID, R2.RECEIPT_NO, R2.RECHARGE_AMT as AMOUNT" >> ${SCRIPT}
echo -e ", R2.TRANSACTION_DTM, R2.RECEIPT_LOCATION_CODE, 0 as FULL" >> ${SCRIPT}
echo -e ", case when R2.RECHARGE_AMT > 3.07 then 'P' else 'F' end as CN_MODE" >> ${SCRIPT}
echo -e ", R2.RECHARGE_CHANNEL, R2.RECHARGE_PARTNER_ID" >> ${SCRIPT}
echo -e "from PM_RECHARGE R2" >> ${SCRIPT}
echo -e "inner join PM_RECHARGE_SERVICE RS on (R2.RECHARGE_CHANNEL = RS.SERVICE_ID" >> ${SCRIPT}
echo -e "and isnull(R2.RECHARGE_PARTNER_ID,0) = isnull(RS.BANK_CODE,0))" >> ${SCRIPT}
echo -e "inner join PM_CFG_RECHARGE_SERVICE CRS on (RS.SERVICE_ROW_ID = CRS.SERVICE_ROW_ID)" >> ${SCRIPT}
echo -e "inner join PM_PAYMENT_CATEGORY PC on (CRS.CATEGORY_CODE = PC.CATEGORY_CODE)" >> ${SCRIPT}
echo -e "left join PM_CFG_REVERSAL_PERIOD RP2 on (PC.CHANNEL_ID = RP2.CHANNEL_ID" >> ${SCRIPT}
echo -e "and CRS.RC_SUB_BOP_ID = RP2.SUB_BOP_ID)" >> ${SCRIPT}
echo -e "inner join PM_DOCUMENT_TYPE D on (R2.DOCUMENT_TYPE_ID = D.DOCUMENT_TYPE_ID)" >> ${SCRIPT}
echo -e "where R2.RECHARGE_DATE >= '20160601' and R2.RECHARGE_DATE <= '20160630'" >> ${SCRIPT}
echo -e "and dateadd(dd, isnull(RP2.PERIOD, 0), R2.RECEIPT_DATE) <= '20160616'" >> ${SCRIPT}
echo -e "and R2.MOBILE_NO = '0854000673'" >> ${SCRIPT}
echo -e "and R2.RECHARGE_AMT >= 3.07" >> ${SCRIPT}
echo -e "and R2.RECEIPT_STATUS = 'N'" >> ${SCRIPT}
echo -e "and R2.CONVERT_TO_RECEIPT_BOO = 'N'" >> ${SCRIPT}
echo -e "and D.DOCUMENT_TYPE = 'B'" >> ${SCRIPT}
echo -e "order by TRANSACTION_DTM, AMOUNT" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${SCRIPT}

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
echo -e ", '20160616', '0854000673', 3.07, @reason_id, 'unit', null" >> ${SCRIPT}
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
STATUS=$(echo ${RESULT} | cut -d '|' -f 1)
MSG=$(echo ${RESULT} | cut -d '|' -f 2)
RECEIPT_ID=$(echo ${RESULT} | cut -d '|' -f 3)
RECEIPT_NO=$(echo ${RESULT} | cut -d '|' -f 4)
RECEIPT_DATE=$(echo ${RESULT} | cut -d '|' -f 5)

# Return
if [ "${STATUS}" != "0" ]; then
  exit $RET_FAIL
fi

#if [ "${MSG}" != "" ]; then
#  exit $RET_FAIL
#fi

if [ "${RECEIPT_ID}" = "" ]; then
  exit $RET_FAIL
fi

if [ "${RECEIPT_NO}" = "" ]; then
  exit $RET_FAIL
fi

if [ "${RECEIPT_DATE}" = "" ]; then
  exit $RET_FAIL
fi

exit $RET_OK

