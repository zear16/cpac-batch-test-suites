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
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=L,PROCESS_STATUS=SC,LOAD_TOTAL=1,LOAD_SUCCESS=1,LOAD_ERROR=0 : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PM_INF_BATCH_ADJ_VALIDITY_40_ADJUST @order_id=${ORDER_ID}
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
echo -e "where ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and BATCH_STATE = 'A' and PROCESS_STATUS = 'SC'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=A,PROCESS_STATUS=SC : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_FILE_ADJUST"  >> ${SCRIPT}
echo -e "where ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_FILE_ADJUST : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_ADJUST_TRANSACTION T"  >> ${SCRIPT}
echo -e "inner join PM_FILE_ADJUST F on (T.FILE_ID = F.FILE_ID)" >> ${SCRIPT}
echo -e "where F.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and T.MOBILE_NO = '0910021163' and T.ADJUST_VALIDITY = 40" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_ADJUST_TRANSACTION with MOBILE_NO=0910021163,ADJUST_VALIDITY=40 : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

exit $RET_OK
