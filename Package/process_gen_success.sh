ORDER_ID=$(cat ${WORKING_PATH}/order_id)

# Expected OK
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

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_INF_PACKAGE_BOS I" >> ${SCRIPT}
echo -e "where I.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_INF_PACKAGE_BOS : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_LOAD_PM_PACKAGE_BOS_FROM_INF @order_id=${ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_PACKAGE_BOS P" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (P.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PACKAGE_BOS : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "select PB.PRODUCT_ID, P.PACKAGE_FEE, P.GEN_RECEIPT_BOO, P.BANK_CODE" >> ${SCRIPT}
echo -e ", D.DOCUMENT_TYPE_ID, B.BOP_ID, SB.SUB_BOP_ID, SM.LOCATION_CODE" >> ${SCRIPT}
echo -e ", PC.CHANNEL_ID, CS.CATEGORY_CODE, S.SERVICE_ID" >> ${SCRIPT}
echo -e "from PM_PACKAGE_BOS PB" >> ${SCRIPT}
echo -e "inner join PM_PACKAGE P on (PB.PRODUCT_ID = P.PACKAGE_CODE)" >> ${SCRIPT}
echo -e "inner join PM_SUB_BUSINESS_OF_PAYMENT SB on (" >> ${SCRIPT}
echo -e "case when P.PACKAGE_TYPE = 'D' then 'DD' else 'DV' end = SB.SUB_BOP_CODE)" >> ${SCRIPT}
echo -e "inner join PM_BUSINESS_OF_PAYMENT B on (SB.BOP_ID = B.BOP_ID)" >> ${SCRIPT}
echo -e "inner join PM_RECHARGE_SERVICE S on (P.BANK_CODE = S.BANK_CODE)" >> ${SCRIPT}
echo -e "inner join PM_CFG_RECHARGE_SERVICE CS on (S.SERVICE_ROW_ID = CS.SERVICE_ROW_ID" >> ${SCRIPT}
echo -e "and CS.RC_SUB_BOP_ID = SB.SUB_BOP_ID)" >> ${SCRIPT}
echo -e "inner join PM_RECHARGE_SERVICE_MAPPING SM on (S.SERVICE_ROW_ID = SM.SERVICE_ROW_ID)" >> ${SCRIPT}
echo -e "inner join PM_DOCUMENT_TYPE D on (S.DOCUMENT_TYPE_ID = D.DOCUMENT_TYPE_ID)" >> ${SCRIPT}
echo -e "inner join PM_PAYMENT_CATEGORY PCA on (CS.CATEGORY_CODE = PCA.CATEGORY_CODE)" >> ${SCRIPT}
echo -e "inner join PM_PAYMENT_CHANNEL PC on (PCA.CHANNEL_ID = PC.CHANNEL_ID)" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH LB on (PB.BATCH_ID = LB.BATCH_ID)" >> ${SCRIPT}
echo -e "where LB.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and P.ACTIVE_BOO = 'Y'" >> ${SCRIPT}
echo -e "group by PB.PRODUCT_ID, P.PACKAGE_FEE, P.GEN_RECEIPT_BOO, P.BANK_CODE" >> ${SCRIPT}
echo -e ", D.DOCUMENT_TYPE_ID, B.BOP_ID, SB.SUB_BOP_ID, SM.LOCATION_CODE" >> ${SCRIPT}
echo -e ", PC.CHANNEL_ID, PC.CHANNEL_CODE, CS.CATEGORY_CODE, S.SERVICE_ID" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PM_PACKAGE_BOS_GEN_RECEIPT @order_id=${ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_PACKAGE_BOS P" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (P.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and P.RECEIPT_ID != null" >> ${SCRIPT}
echo -e "\nprint '%1!', @count\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PACKAGE_BOS with RECEIPT_ID!=null : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @receipt_id unsigned bigint" >> ${SCRIPT}
echo -e "select @receipt_id = RECEIPT_ID" >> ${SCRIPT}
echo -e "from PM_PACKAGE_BOS P" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (P.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @receipt_id\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/receipt_id

RECEIPT_ID=$(cat ${WORKING_PATH}/receipt_id)

# Check BATCH_NO, SERIAL_NO

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "select DP.PREPAID_BATCH_NO, DP.PREPAID_SERIAL_NO" >> ${SCRIPT}
echo -e "from PM_RECEIPT_DTL_PREPAID DP" >> ${SCRIPT}
echo -e "inner join PM_RECEIPT_DTL D on (DP.RECEIPT_DTL_ID = D.RECEIPT_DTL_ID)" >> ${SCRIPT}
echo -e "where D.RECEIPT_ID = ${RECEIPT_ID}" >> ${SCRIPT}
echo -e "and DP.RECEIPT_DATE = '20160616'" >> ${SCRIPT}
echo -e "and D.RECEIPT_DATE = '20160616'" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_RECEIPT_DTL_PREPAID DP" >> ${SCRIPT}
echo -e "inner join PM_RECEIPT_DTL D on (DP.RECEIPT_DTL_ID = D.RECEIPT_DTL_ID)" >> ${SCRIPT}
echo -e "where D.RECEIPT_ID = ${RECEIPT_ID}" >> ${SCRIPT}
echo -e "and DP.RECEIPT_DATE = '20160616'" >> ${SCRIPT}
echo -e "and D.RECEIPT_DATE = '20160616'" >> ${SCRIPT}
echo -e "and DP.PREPAID_BATCH_NO = '0017160116'" >> ${SCRIPT}
echo -e "and DP.PREPAID_SERIAL_NO = '0616135839'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo -e "found PM_RECEIPT_DTL_PREPAID with RECEIPT_ID=${RECEIPT_ID},RECEIPT_DATE=20160616"
echo -e "      ,PREPAID_BATCH_NO=0017160116,PREPAID_SERIAL_NO=0616135839 : ${COUNT}"

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

