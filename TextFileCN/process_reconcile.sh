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
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=C,PROCESS_STATUS=SC : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

${EXECUTE_PATH}/reconcile -c ${CONFIG_NAME} --order-id ${ORDER_ID}
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
#echo -e "inner join PM_FILE_CONFIG_VERSION V on (O.VERSION_ID = V.VERSION_ID)" >> ${SCRIPT}
#echo -e "inner join PM_RECONCILE_MAPPING M on (V.VERSION_ID = M.VERSION_ID)" >> ${SCRIPT}
echo -e "inner join PM_FILE_CONFIG F on (O.TEMPLATE_CODE = F.TEMPLATE_CODE)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING M on (F.FILE_TYPE = M.FILE_TYPE)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING_TABLE MT on (M.RECONCILE_ID = MT.RECONCILE_ID and T.TABLE_ID = MT.TABLE_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and MT.TABLE_NAME = 'PM_BATCH_PP_CN'" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '012'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE with RECONCILE_CODE=012,TABLE_NAME=PM_BATCH_PP_CN : ${COUNT}"
if [ "$COUNT" -ne "0" ]; then
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
#echo -e "inner join PM_FILE_CONFIG_VERSION V on (O.VERSION_ID = V.VERSION_ID)" >> ${SCRIPT}
#echo -e "inner join PM_RECONCILE_MAPPING M on (V.VERSION_ID = M.VERSION_ID)" >> ${SCRIPT}
echo -e "inner join PM_FILE_CONFIG F on (O.TEMPLATE_CODE = F.TEMPLATE_CODE)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING M on (F.FILE_TYPE = M.FILE_TYPE)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING_TABLE MT on (M.RECONCILE_ID = MT.RECONCILE_ID and T.TABLE_ID = MT.TABLE_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and MT.TABLE_NAME = 'PM_ADJUST_TRANSACTION'" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '012'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE with RECONCILE_CODE=012,TABLE_NAME=PM_ADJUST_TRANSACTION : ${COUNT}"
if [ "$COUNT" -ne "0" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_PREPAID_BATCH_RECONCILE R" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '012'" >> ${SCRIPT}
echo -e "and R.DIFF_BOO = 'N'" >> ${SCRIPT}
echo -e "and R.LAST_BOO = 'Y'" >> ${SCRIPT}
echo -e "and R.REF_1_RECORD = 1" >> ${SCRIPT}
echo -e "and R.REF_1_AMT = -39.94" >> ${SCRIPT}
echo -e "and R.REF_1_VALIDITY = 0" >> ${SCRIPT}
echo -e "and R.REF_2_RECORD = 1" >> ${SCRIPT}
echo -e "and R.REF_2_AMT = -39.94" >> ${SCRIPT}
echo -e "and R.REF_2_VALIDITY = 0" >> ${SCRIPT}
echo -e "and R.REF_1_L_REF_2_RECORD = 0" >> ${SCRIPT}
echo -e "and R.REF_1_L_REF_2_AMT = 0" >> ${SCRIPT}
echo -e "and R.REF_1_L_REF_2_VALIDITY = 0" >> ${SCRIPT}
echo -e "and R.REF_1_M_REF_2_RECORD = 0" >> ${SCRIPT}
echo -e "and R.REF_1_M_REF_2_AMT = 0" >> ${SCRIPT}
echo -e "and R.REF_1_M_REF_2_VALIDITY = 0" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_BATCH_RECONCILE with RECONCILE_CODE=012,LAST_BOO=Y,DIFF_BOO=N"
echo "      ,REF_1_RECORD=1,REF_1_AMT=-39.94,REF_1_VALIDITY=0"
echo "      ,REF_2_RECORD=1,REF_2_AMT=-39.94,REF_2_VALIDITY=0"
echo "      ,REF_1_L_REF_2_RECORD=0,REF_1_L_REF_2_AMT=0,REF_1_L_REF_2_VALIDITY=0"
echo "      ,REF_1_M_REF_2_RECORD=0,REF_1_M_REF_2_AMT=0,REF_1_M_REF_2_VALIDITY=0 : ${COUNT}"
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

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=R,PROCESS_STATUS=SC : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

exit $RET_OK

