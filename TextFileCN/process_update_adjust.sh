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
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_LOAD_BATCH with LOAD_TOTAL=1,LOAD_SUCCESS=1,LOAD_ERROR=0 : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
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
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_LOAD_BATCH_REJECT : ${COUNT}"

if [ "$COUNT" -ne "0" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_INF_BATCH_PP_CN"  >> ${SCRIPT}
echo -e "where ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_INF_BATCH_PP_CN : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_LOAD_PM_BATCH_PP_CN_FROM_INF @order_id=${ORDER_ID}
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
echo -e "from PM_BATCH_PP_CN R"  >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_BATCH_PP_CN  : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_PREPAID_LOAD_BATCH" >> ${SCRIPT}
echo -e "where ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and BATCH_STATE = 'C'" >> ${SCRIPT}
echo -e "and PROCESS_STATUS = 'SC'" >> ${SCRIPT}
echo -e "and TOTAL_AMT = -39.94" >> ${SCRIPT}
echo -e "and SUCCESS_AMT = -39.94" >> ${SCRIPT}
echo -e "and ERROR_AMT = 0" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo -e "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=C,PROCESS_STATUS=SC"
echo -e "      ,TOTAL_AMT=-39.94,SUCCESS_AMT=-39.94,ERROR_AMT=0 : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

ADJUST_ID=$(cat ${WORKING_PATH}/adjust_id)
CN_NO=$(cat ${WORKING_PATH}/cn_no)
CN_DATE=$(cat ${WORKING_PATH}/cn_date)

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_ADJUST_TRANSACTION" >> ${SCRIPT}
echo -e "where ADJUST_ID = ${ADJUST_ID}" >> ${SCRIPT}
echo -e "and CN_NO = '${CN_NO}'" >> ${SCRIPT}
echo -e "and CN_DATE = '${CN_DATE}'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_ADJUST_TRANSACTION with ADJUST_ID=${ADJUST_ID},CN_NO=${CN_NO},CN_DATE=${CN_DATE} : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

exit $RET_OK

