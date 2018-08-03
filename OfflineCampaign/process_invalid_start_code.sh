ORDER_ID=$(cat ${WORKING_PATH}/order_id)

# Expected error
${EXECUTE_PATH}/prepaid_loader -c ${CONFIG_NAME} --order-id ${ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_PREPAID_LOAD_BATCH"  >> ${SCRIPT}
echo -e "where ORDER_ID = ${ORDER_ID} and LOAD_TOTAL = 1 and LOAD_SUCCESS = 1 and LOAD_ERROR = 0" >> ${SCRIPT}
echo -e "and BATCH_STATE = 'L' and PROCESS_STATUS = 'SC'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=L,PROCESS_STATUS=SC,LOAD_TOTAL=1,LOAD_SUCCESS=1,LOAD_ERROR=0 : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

select PB.ORDER_LINE_NO, ACCT_ID, START_CODE, NEGATIVE_CODE, MAX_BALANCE, GENDOC_CODE
, POCKET_CODE, isnull(ADJ_AMT,0), AI.MOBILE_NO, 0, AI.STATUS_CD
from PM_INF_BATCH_CAMPAIGN PB
left join CPDB..SFF_ASSET_INSTANCE AI on (PB.MOBILE_NO = AI.MOBILE_NO)
left join CPDB..SFF_ACCOUNT BA on (AI.BILLING_ACCNT_ID = BA.ROW_ID)
where PB.ORDER_ID = ${ORDER_ID}
--and (AI.STATUS_CD in (select STATUS_DESC from PM_CFG_ACCOUNT_STATE where STATE_ACTIVE_BOO = 'Y')
--or (AI.STATUS_DT = (select max(STATUS_DT)
--                        from CPDB..SFF_ASSET_INSTANCE SAI
--                        where SAI.MOBILE_NO = AI.MOBILE_NO)
--    and 0 = (select count(*)
--                        from CPDB..SFF_ASSET_INSTANCE SAI
--                        where MOBILE_NO = AI.MOBILE_NO
--                        and STATUS_CD in (select STATUS_DESC from PM_CFG_ACCOUNT_STATE where STATE_ACTIVE_BOO = 'Y'))
--    ))
order by PB.ORDER_LINE_NO

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} -Jutf8 -w200

# Expected error
${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_LOAD_PM_BATCH_CAMPAIGN_FROM_INF @order_id=${ORDER_ID}
RET=$?
if [ $RET -ne 1 ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_PREPAID_LOAD_BATCH_REJECT R"  >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and R.SEQ_NO = 1 and R.FIELD_NAME = 'START_CODE' and R.REMARK = 'Invalid START_CODE'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -w200 -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_LOAD_BATCH_REJECT with SEQ_NO=1,FIELD_NAME=START_CODE,REMARK=Invalid START_CODE : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_PREPAID_LOAD_BATCH"  >> ${SCRIPT}
echo -e "where ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and BATCH_STATE = 'C' and PROCESS_STATUS = 'FL'" >> ${SCRIPT}
#echo -e "and LOAD_TOTAL = 1 and LOAD_SUCCESS = 0 and LOAD_ERROR = 1" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=C,PROCESS_STATUS=FL : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

exit $RET_OK

