ORDER_ID=$(cat ${WORKING_PATH}/order_id)

# Save Old value for ServiceId 902 (ePin)

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @flag char(1)" >> ${SCRIPT}
echo -e "select @flag = RECHARGE_BOO from PM_RECHARGE_SERVICE where SERVICE_ID = 902" >> ${SCRIPT}
echo -e "\nprint '%1!', @flag" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/save_recharge_boo

SAVE_RECHARGE_BOO=$(cat ${WORKING_PATH}/save_recharge_boo)

# Update ServiceId 902 (ePin) to 'Y' to test this case

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "update PM_RECHARGE_SERVICE set RECHARGE_BOO = 'Y' where SERVICE_ID = 902" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

# Expected OK
${EXECUTE_PATH}/recharge -c ${CONFIG_NAME} --order-id ${ORDER_ID}
RET=$?

# Restore ServiceId 902 (ePin) to old value immediately

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "update PM_RECHARGE_SERVICE set RECHARGE_BOO = '${SAVE_RECHARGE_BOO}'" >> ${SCRIPT}
echo -e "where SERVICE_ID = 902" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

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

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_RECHARGE R" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_RECHARGE : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

# Update ServiceId 902 (ePin) to 'Y' to test this case

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "update PM_RECHARGE_SERVICE set RECHARGE_BOO = 'Y' where SERVICE_ID = 902" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PM_RECHARGE_GEN_RECEIPT @order_id=${ORDER_ID}
RET=$?

# Restore ServiceId 902 (ePin) to old value immediately

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "update PM_RECHARGE_SERVICE set RECHARGE_BOO = '${SAVE_RECHARGE_BOO}'" >> ${SCRIPT}
echo -e "where SERVICE_ID = 902" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_RECHARGE R" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and R.RECORD_STATUS = 'IC'" >> ${SCRIPT}
echo -e "and R.CSC_RECEIPT_ID != null" >> ${SCRIPT}
echo -e "\nprint '%1!', @count\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_RECHARGE with RECORD_STATUS=IC, CSC_RECEIPT_ID<>null : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_RECHARGE_GEN_RECEIPT_STATE S" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (S.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and S.CUR_NO = S.MAX_NO" >> ${SCRIPT}
echo -e "\nprint '%1!', @count\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_RECHARGE_GEN_RECEIPT with CUR_NO=MAX_NO : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_PREPAID_LOAD_BATCH" >> ${SCRIPT}
echo -e "where ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and BATCH_STATE = 'G' and PROCESS_STATUS = 'SC'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=G,PROCESS_STATUS=SC : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

exit $RET_OK

