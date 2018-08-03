ORDER_ID=$(cat ${WORKING_PATH}/order_id)

# Call procedure PM_S_TX_LOAD_PM_BATCH_CONVERT_POST_PRE_FROM_SFF
${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_LOAD_PM_BATCH_CONVERT_POST_PRE_FROM_SFF @order_id=${ORDER_ID}
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
echo -e "from PM_BATCH_CONVERT_POST_PRE C"  >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (C.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and C.BILLING_SYSTEM = 'RTBS'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_BATCH_CONVERT_POST_PRE with BILLING_SYSTEM=RTBS: ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

# Call procedure PM_S_TX_PROCESS_CONVERT_POST_TO_PRE
${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PROCESS_CONVERT_POST_TO_PRE @order_id=${ORDER_ID}
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
echo -e "from PM_BATCH_CONVERT_POST_PRE C"  >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (C.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and STATUS = 'SC'" >> ${SCRIPT}
echo -e "and EXCESS_BAL_ID = NULL" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_BATCH_CONVERT_POST_PRE with STATUS=SC,EXCESS_BAL_ID=NULL : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_INF_PLUGIN_PREPAID_CN_EXCESS I"  >> ${SCRIPT}
echo -e "where I.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_INF_PLUGIN_PREPAID_CN_EXCESS : ${COUNT}"
if [ "$COUNT" -ne "0" ]; then
  exit $RET_FAIL
fi

return $RET_OK

