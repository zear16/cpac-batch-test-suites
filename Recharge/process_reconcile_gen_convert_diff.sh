ORDER_ID=$(cat ${WORKING_PATH}/order_id)

# Expected OK
${EXECUTE_PATH}/recharge -c ${CONFIG_NAME} --order-id ${ORDER_ID}
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
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

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
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_RECHARGE : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PM_RECHARGE_GEN_RECEIPT @order_id=${ORDER_ID}
RET=$?
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
echo -e "and R.RECEIPT_NO != null" >> ${SCRIPT}
echo -e "\nprint '%1!', @count\n\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_RECHARGE with RECEIPT_NO!=null : ${COUNT}"

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
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=G,PROCESS_STATUS=SC : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

# Update CONVERT_TO_RECEIPT_BOO='Y'

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "\nupdate PM_RECHARGE set CONVERT_TO_RECEIPT_BOO = 'Y'" >> ${SCRIPT}
echo -e "from PM_RECHARGE R" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

ORDER_ID=$(cat ${WORKING_PATH}/reconcile_order_id)

# Replace old order_id file
cp ${WORKING_PATH}/reconcile_order_id ${WORKING_PATH}/order_id

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "\nselect R.RECHARGE_ID, R.RECHARGE_CHANNEL as SERVICE_ID, R.RECHARGE_PARTNER_ID as BANK_CODE, R.MOBILE_NO" >> ${SCRIPT}
echo -e ", convert(char(8), R.RECHARGE_DATE, 112) as TRANSACTION_DATE, R.RECHARGE_AMT as TOTAL_AMT" >> ${SCRIPT}
echo -e ", R.CARD_BATCH_ID ||  R.CARD_SERIAL_NO  as BATCH_NO, R.RECEIPT_NO, R.RECEIPT_DATE, R.RECEIPT_STATUS" >> ${SCRIPT}
echo -e " from PM_RECHARGE R" >> ${SCRIPT}
echo -e " where R.RECHARGE_DATE = '20160616'" >> ${SCRIPT}
echo -e " and R.SPECIFICATION_ID <> 1009001" >> ${SCRIPT}
echo -e " and R.IS_TEST_NUMBER_BOO = 'N'" >> ${SCRIPT}
echo -e " and R.RECORD_STATUS != NULL" >> ${SCRIPT}
echo -e " order by SERVICE_ID, BANK_CODE, MOBILE_NO, BATCH_NO, TOTAL_AMT" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

#isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "\nselect '1' as SOURCE, R.RECHARGE_CHANNEL as SERVICE_ID, R.RECHARGE_PARTNER_ID as BANK_CODE, R.MOBILE_NO" >> ${SCRIPT}
echo -e ", convert(char(8), R.RECHARGE_DATE, 112) as TRANSACTION_DATE, R.RECEIPT_AMT as TOTAL_AMT" >> ${SCRIPT}
echo -e ", R.CARD_BATCH_ID ||  R.CARD_SERIAL_NO  as BATCH_NO, R.RECEIPT_NO, R.RECEIPT_DATE, R.RECEIPT_STATUS" >> ${SCRIPT}
echo -e " from PM_RECHARGE R" >> ${SCRIPT}
echo -e " where R.RECHARGE_DATE = '20160616'" >> ${SCRIPT}
echo -e " and R.SPECIFICATION_ID <> 1009001" >> ${SCRIPT}
echo -e " and R.IS_TEST_NUMBER_BOO = 'N'" >> ${SCRIPT}
echo -e " and R.CONVERT_TO_RECEIPT_BOO = 'N'" >> ${SCRIPT}
echo -e " and R.RECEIPT_NO is not null" >> ${SCRIPT}
echo -e " union all" >> ${SCRIPT}
echo -e " select '2' as SOURCE, RP.SERVICE_ID, R.BANK_CODE, RD.MOBILE_NO" >> ${SCRIPT}
echo -e ", R.RECEIPT_DATE as TRANSACTION_DATE, RD.TOTAL_AMT" >> ${SCRIPT}
echo -e ", RDP.PREPAID_BATCH_NO || RDP.PREPAID_SERIAL_NO as BATCH_NO, R.RECEIPT_NO, R.RECEIPT_DATE, R.RECEIPT_STATUS" >> ${SCRIPT}
echo -e " from PM_RECEIPT_DTL RD" >> ${SCRIPT}
echo -e " inner join PM_RECEIPT_DTL_PREPAID RDP on (RD.RECEIPT_DTL_ID = RDP.RECEIPT_DTL_ID and RD.RECEIPT_DATE = RDP.RECEIPT_DATE)" >> ${SCRIPT}
echo -e " inner join PM_RECEIPT R on (RD.RECEIPT_ID = R.RECEIPT_ID and RD.RECEIPT_DATE = R.RECEIPT_DATE)" >> ${SCRIPT}
echo -e " inner join PM_RECEIPT_PREPAID RP on (R.RECEIPT_ID = RP.RECEIPT_ID and R.RECEIPT_DATE = RP.RECEIPT_DATE)" >> ${SCRIPT}
echo -e " inner join PM_SUB_BUSINESS_OF_PAYMENT BOP on (RD .SUB_BOP_ID = BOP.SUB_BOP_ID)" >> ${SCRIPT}
echo -e " where RD.RECEIPT_DATE = '20160616'" >> ${SCRIPT}
echo -e " and BOP.SUB_BOP_CODE = 'PT'" >> ${SCRIPT}
echo -e " order by SERVICE_ID, BANK_CODE, MOBILE_NO, BATCH_NO, TOTAL_AMT" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

#isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

${EXECUTE_PATH}/reconcile -c ${CONFIG_NAME} --order-id=${ORDER_ID}
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
echo -e "from PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE T" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_BATCH_RECONCILE_DIFF D on (T.DIFF_ID = D.DIFF_ID)" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_BATCH_RECONCILE R on (D.BATCH_RCC_ID = R.BATCH_RCC_ID)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "inner join PM_JOB_ORDER O on (B.ORDER_ID = O.ORDER_ID)" >> ${SCRIPT}
echo -e "inner join PM_FILE_CONFIG F on (O.TEMPLATE_CODE = F.TEMPLATE_CODE)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING M on (F.FILE_TYPE = M.FILE_TYPE)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING_TABLE MT on (M.RECONCILE_ID = MT.RECONCILE_ID and T.TABLE_ID = MT.TABLE_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and MT.TABLE_NAME = 'PM_RECHARGE'" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '001'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE with RECONCILE_CODE=001,TABLE_NAME=PM_RECHARGE : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "select D.D_MOBILE_NO, D.TRANS_DTM, D.FACE_VALUE, D.VALIDITY" >> ${SCRIPT}
echo -e "from PM_PREPAID_BATCH_RECONCILE_DIFF D" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_BATCH_RECONCILE R on (D.BATCH_RCC_ID = R.BATCH_RCC_ID)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '001'" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

#isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_PREPAID_BATCH_RECONCILE_DIFF D" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_BATCH_RECONCILE R on (D.BATCH_RCC_ID = R.BATCH_RCC_ID)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and D.D_MOBILE_NO = '0817053436'" >> ${SCRIPT}
echo -e "and D.TRANS_DTM = '20160616'" >> ${SCRIPT}
echo -e "and D.FACE_VALUE = 6746" >> ${SCRIPT}
echo -e "and D.VALIDITY = null" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '001'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_BATCH_RECONCILE_DIFF with RECONCILE_CODE=001,D_MOBILE_NO=0817053436,TRANS_DTM=20160616,FACE_VALUE=6746,VALIDITY=null : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "select DIFF_BOO, LAST_BOO, REF_1_RECORD, REF_1_AMT, REF_1_VALIDITY" >> ${SCRIPT}
echo -e ", REF_2_RECORD, REF_2_AMT, REF_2_VALIDITY, REF_1_L_REF_2_RECORD" >> ${SCRIPT}
echo -e ", REF_1_L_REF_2_AMT, REF_1_L_REF_2_VALIDITY, REF_1_M_REF_2_RECORD" >> ${SCRIPT}
echo -e ", REF_1_M_REF_2_AMT, REF_1_M_REF_2_VALIDITY" >> ${SCRIPT}
echo -e "from PM_PREPAID_BATCH_RECONCILE R" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '001'" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

#isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_PREPAID_BATCH_RECONCILE R" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '001'" >> ${SCRIPT}
echo -e "and R.DIFF_BOO = 'Y'" >> ${SCRIPT}
echo -e "and R.LAST_BOO = 'Y'" >> ${SCRIPT}
echo -e "and R.REF_1_RECORD = 1" >> ${SCRIPT}
echo -e "and R.REF_1_AMT = 6746" >> ${SCRIPT}
echo -e "and R.REF_1_VALIDITY = 0" >> ${SCRIPT}
echo -e "and R.REF_2_RECORD = 0" >> ${SCRIPT}
echo -e "and R.REF_2_AMT = 0" >> ${SCRIPT}
echo -e "and R.REF_2_VALIDITY = 0" >> ${SCRIPT}
echo -e "and R.REF_1_L_REF_2_RECORD = 1" >> ${SCRIPT}
echo -e "and R.REF_1_L_REF_2_AMT = 6746" >> ${SCRIPT}
echo -e "and R.REF_1_L_REF_2_VALIDITY = 0" >> ${SCRIPT}
echo -e "and R.REF_1_M_REF_2_RECORD = 0" >> ${SCRIPT}
echo -e "and R.REF_1_M_REF_2_AMT = 0" >> ${SCRIPT}
echo -e "and R.REF_1_M_REF_2_VALIDITY = 0" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_BATCH_RECONCILE with RECONCILE_CODE=001,LAST_BOO=Y,DIFF_BOO=Y"
echo "      ,REF_1_RECORD=1,REF_1_AMT=6746,REF_1_VALIDITY=0"
echo "      ,REF_2_RECORD=0,REF_2_AMT=0,REF_2_VALIDITY=0"
echo "      ,REF_1_L_REF_2_RECORD=1,REF_1_L_REF_2_AMT=6746,REF_1_L_REF_2_VALIDITY=0"
echo "      ,REF_1_M_REF_2_RECORD=0,REF_1_M_REF_2_AMT=0,REF_1_M_REF_2_VALIDITY=0 : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "
use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_PREPAID_LOAD_BATCH B
inner join PM_PREPAID_BATCH_RECONCILE BR on (B.BATCH_ID = BR.BATCH_ID)
inner join PM_PREPAID_BATCH_RECONCILE_DTL RD on (BR.BATCH_RCC_ID = RD.BATCH_RCC_ID)
where B.ORDER_ID = ${ORDER_ID}

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_BATCH_RECONCILE_DTL : ${COUNT}"
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
echo -e "and BATCH_STATE = 'R'" >> ${SCRIPT}
echo -e "and PROCESS_STATUS = 'SC'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=R,PROCESS_STATUS=SC : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

exit $RET_OK

