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
echo -e "and STATUS = 'PR'" >> ${SCRIPT}
echo -e "and EXCESS_BAL_ID != NULL" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_BATCH_CONVERT_POST_PRE with STATUS=SC,EXCESS_BAL_ID<>NULL : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
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
echo -e "inner join PM_EXCESS_BALANCE E on (C.EXCESS_BAL_ID = E.EXCESS_ID)" >> ${SCRIPT}
echo -e "inner join PM_RECEIPT_DTL RD on (E.RECEIPT_DTL_ID = RD.RECEIPT_DTL_ID" >> ${SCRIPT}
echo -e "and E.EXCESS_DATE = RD.RECEIPT_DATE)" >> ${SCRIPT}
echo -e "inner join PM_RECEIPT R on (RD.RECEIPT_ID = R.RECEIPT_ID" >> ${SCRIPT}
echo -e "and RD.RECEIPT_DATE = R.RECEIPT_DATE)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and R.RECEIPT_STATUS = 'W'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_RECEIPT with RECEIPT_STATUS=W : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_JOB_ORDER O"  >> ${SCRIPT}
echo -e "where O.TEMPLATE_CODE = 'EXP_PLUGIN_PREPAID_CN_EXCESS'" >> ${SCRIPT}
echo -e "and O.REF_ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and O.ORDER_TYPE = 'E'" >> ${SCRIPT}
#echo -e "and O.ORDER_STATUS = 'W'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_JOB_ORDER with TEMPLATE_CODE=EXP_PLUGIN_PREPAID_CN_EXCESS,REF_ORDER_ID=${ORDER_ID}"
echo "                        ,ORDER_TYPE=E,ORDER_STATUS=W : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

# Make sure that status will be 'W'

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "update PM_JOB_ORDER set ORDER_STATUS = 'W'" >> ${SCRIPT}
echo -e "where TEMPLATE_CODE = 'EXP_PLUGIN_PREPAID_CN_EXCESS'" >> ${SCRIPT}
echo -e "and REF_ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and ORDER_TYPE = 'E'" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}
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
echo -e "inner join PM_BATCH_CONVERT_POST_PRE_SEND_ORDER S on (C.BATCH_ID = S.BATCH_ID)" >> ${SCRIPT}
echo -e "inner join PM_JOB_ORDER O on (S.ORDER_ID = O.ORDER_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and O.TEMPLATE_CODE = 'EXP_PLUGIN_PREPAID_CN_EXCESS'" >> ${SCRIPT}
echo -e "and S.ORDER_STATUS = 'W'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_BATHC_CONVERT_POST_PRE_SEND_ORDER with ORDER TEMPLATE=EXP_PLUGIN_PREPAID_CN_EXCESS"
echo "                                                , ORDER_STATUS=W : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

# Update ORDER to SUCCESS

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_UPDATE_ORDER_STATUS @order_id=${ORDER_ID} @status=S @description=''
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

# For now we go to chain Plugin Prepaid Credit Note Excess

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "update PM_JOB_ORDER set ORDER_STATUS = 'W'" >> ${SCRIPT}
echo -e "where TEMPLATE_CODE = 'EXP_PLUGIN_PREPAID_CN_EXCESS'" >> ${SCRIPT}
echo -e "and REF_ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and ORDER_TYPE = 'E'" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

# Ignore ORDER_STATUS cause if JobOrderDaemon is alive this status may change
SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @new_order_id unsigned bigint" >> ${SCRIPT}
echo -e "select @new_order_id = ORDER_ID" >> ${SCRIPT}
echo -e "from PM_JOB_ORDER O"  >> ${SCRIPT}
echo -e "where O.TEMPLATE_CODE = 'EXP_PLUGIN_PREPAID_CN_EXCESS'" >> ${SCRIPT}
echo -e "and O.REF_ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and O.ORDER_TYPE = 'E'" >> ${SCRIPT}
#echo -e "and O.ORDER_STATUS = 'W'" >> ${SCRIPT}
echo -e "\nprint '%1!', @new_order_id" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/new_order_id
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

NEW_ORDER_ID=$(cat ${WORKING_PATH}/new_order_id)

echo "${NEW_ORDER_ID}"

# Call procedure PM_S_TX_PROCESS_CONVERT_POST_TO_PRE
${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_LOAD_PM_INF_PLUGIN_PREPAID_CN_EXCESS_FROM_TRANS @order_id=${NEW_ORDER_ID}
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
echo -e "from PM_INF_PLUGIN_PREPAID_CN_EXCESS I"  >> ${SCRIPT}
echo -e "where I.ORDER_ID = ${NEW_ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_INF_PLUGIN_PREPAID_CN_EXCESS : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

# export file
${EXECUTE_PATH}/loader -c ${CONFIG_NAME} --order-id ${NEW_ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

# Check file
SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @param varchar(1000)" >> ${SCRIPT}
echo -e "select @param = FILE_NAME || ' ' ||  SOURCE_CTRL_NAME || ' ' || FILE_PATH" >> ${SCRIPT}
echo -e "from PM_JOB_ORDER"  >> ${SCRIPT}
echo -e "where ORDER_ID = ${NEW_ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @param" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/param
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
PARAM=($(cat ${WORKING_PATH}/param))
echo "${PARAM[2]}/${PARAM[0]}"
if [ ! -f "${PARAM[2]}/${PARAM[0]}" ]; then
  exit $RET_FAIL
fi
cat ${PARAM[2]}/${PARAM[0]}
echo "${PARAM[2]}/${PARAM[1]}"
if [ ! -f "${PARAM[2]}/${PARAM[1]}" ]; then
  exit $RET_FAIL
fi
cat ${PARAM[2]}/${PARAM[1]}


# Call Plugin Prepaid Mockup

${EXECUTE_PATH}/plugin_mockup -c ${CONFIG_NAME} --file-name ${PARAM[2]}/${PARAM[0]} --process-type cn_excess

OUT_PATH=${PLUGIN_TOPUP_OUTPUT_PATH}
NAME_PART=${PARAM[0]:0:29}

if [ ! -f "${OUT_PATH}/${NAME_PART}.sync" ]; then
  echo "${OUT_PATH}/${NAME_PART}.sync not found"
  exit $RET_FAIL
fi
cat ${OUT_PATH}/${NAME_PART}.sync

if [ ! -f "${OUT_PATH}/${NAME_PART}.dat" ]; then
  echo "${OUT_PATH}/${NAME_PART}.dat not found"
  exit $RET_FAIL
fi
cat ${OUT_PATH}/${NAME_PART}.dat

# Create Job to Process Response file
# We set NEXT_PROCESS_DTM to NULL to prevent JobOrderDaemon process

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "\ndeclare @order_id unsigned bigint" >> ${SCRIPT}
echo -e "\ninsert into PM_JOB_ORDER " >> ${SCRIPT}
echo -e "(ORDER_TYPE, TEMPLATE_CODE, JOB_CHAIN, ORDER_MODE, RUN_DATE" >> ${SCRIPT}
echo -e ", DATA_DATE_FR, DATA_DATE_TO, VERSION_ID" >> ${SCRIPT}
echo -e ", FILE_NAME, ORIGINAL_FILE_NAME, SOURCE_CTRL_NAME" >> ${SCRIPT}
echo -e ", FILE_PATH, SOURCE_CTRL_PATH, SOURCE_DATA_PATH" >> ${SCRIPT}
echo -e ", ORDER_STATUS)" >> ${SCRIPT}
echo -e "select 'I', max(F.TEMPLATE_CODE), max(M.JOB_CHAIN), 'A', '20160616'" >> ${SCRIPT}
echo -e ", '20160615', '20160615', max(V.VERSION_ID)" >> ${SCRIPT}
echo -e ", '${NAME_PART}.dat', '${NAME_PART}.dat', '${NAME_PART}.sync'" >> ${SCRIPT}
echo -e ", '${OUT_PATH}', '${OUT_PATH}', '${OUT_PATH}'" >> ${SCRIPT}
echo -e ", 'W'" >> ${SCRIPT}
echo -e "from PM_FILE_CONFIG_VERSION V" >> ${SCRIPT}
echo -e "inner join PM_FILE_CONFIG F on (V.FILE_CONFIG_ID = F.FILE_CONFIG_ID)" >> ${SCRIPT}
echo -e "inner join PM_JOB_SCHEDULER_MAPPING M on (F.TEMPLATE_CODE = M.TEMPLATE_CODE)" >> ${SCRIPT}
echo -e "where F.TEMPLATE_CODE = 'PLUGIN_PREPAID_CN_EXCESS'" >> ${SCRIPT}
echo -e "and V.EFFECTIVE_DATE <= getdate()" >> ${SCRIPT}
echo -e "and (V.EXPIRY_DATE = null or V.EXPIRY_DATE > getdate())" >> ${SCRIPT}
echo -e "\nselect @order_id = @@identity" >> ${SCRIPT}
echo -e "\nprint '%1!', @order_id" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/chk_order_id
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
CHK_ORDER_ID=($(cat ${WORKING_PATH}/chk_order_id))

# Load Response file
${EXECUTE_PATH}/loader -c ${CONFIG_NAME} --order-id ${CHK_ORDER_ID}
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
echo -e "from PM_INF_PLUGIN_PREPAID_CN_EXCESS_D I"  >> ${SCRIPT}
echo -e "where I.ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_INF_PLUGIN_PREPAID_CN_EXCESS_D : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

# process Response Data
${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PROCESS_PLUGIN_PREPAID_CN_EXCESS_RESPONSE @order_id=${CHK_ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

# Check Result

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_BATCH_CONVERT_POST_PRE C"  >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (C.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and CN_ID != NULL" >> ${SCRIPT}
echo -e "and RECEIPT_ID = NULL" >> ${SCRIPT}
echo -e "and STATUS = 'SC'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_BATCH_CONVERT_POST_PRE with STATUS=SC,CN_ID!=NULL,RECEIPT_ID=NULL : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
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
echo -e "inner join PM_BATCH_CONVERT_POST_PRE_SEND_ORDER S on (C.BATCH_ID = S.BATCH_ID)" >> ${SCRIPT}
echo -e "inner join PM_JOB_ORDER O on (S.ORDER_ID = O.ORDER_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and O.TEMPLATE_CODE = 'EXP_PLUGIN_PREPAID_CN_EXCESS'" >> ${SCRIPT}
echo -e "and S.ORDER_STATUS = 'S'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_BATHC_CONVERT_POST_PRE_SEND_ORDER with ORDER TEMPLATE=EXP_PLUGIN_PREPAID_CN_EXCESS"
echo "                                                , ORDER_STATUS=S : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

# Exit here

rm ${PLUGIN_TOPUP_OUTPUT_PATH}/${NAME_PART}.sync
rm ${PLUGIN_TOPUP_OUTPUT_PATH}/${NAME_PART}.dat
rm ${PARAM[2]}/${PARAM[0]}
rm ${PARAM[2]}/${PARAM[1]}

return $RET_OK

# Create Job to Reconcile
# We set NEXT_PROCESS_DTM to NULL to prevent JobOrderDaemon process

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "\ndeclare @order_id unsigned bigint" >> ${SCRIPT}
echo -e "\ninsert into PM_JOB_ORDER " >> ${SCRIPT}
echo -e "(ORDER_TYPE, TEMPLATE_CODE, JOB_CHAIN, ORDER_MODE, RUN_DATE" >> ${SCRIPT}
echo -e ", DATA_DATE_FR, DATA_DATE_TO" >> ${SCRIPT}
echo -e ", ORDER_STATUS)" >> ${SCRIPT}
echo -e "select 'P', max(M.TEMPLATE_CODE), max(M.JOB_CHAIN), 'A', getdate()" >> ${SCRIPT}
echo -e ", getdate(), getdate()" >> ${SCRIPT}
echo -e ", 'W'" >> ${SCRIPT}
echo -e "from PM_JOB_SCHEDULER_MAPPING M" >> ${SCRIPT}
echo -e "where M.TEMPLATE_CODE = 'RECONCILE_CONVERT_POST_TO_PRE'" >> ${SCRIPT}
echo -e "\nselect @order_id = @@identity" >> ${SCRIPT}
echo -e "\nprint '%1!', @order_id" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/rec_order_id
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
REC_ORDER_ID=($(cat ${WORKING_PATH}/rec_order_id))

# Check If ORDER ready for reconcile

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_VALIDATE_RELATE_CONVERT_POST_PRE @order_id=${REC_ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

# Call reconcile
${EXECUTE_PATH}/reconcile -c ${CONFIG_NAME} --order-id=${REC_ORDER_ID}
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
echo -e "inner join PM_RECONCILE_MAPPING M on (O.TEMPLATE_CODE = M.FILE_TYPE)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING_TABLE MT on (M.RECONCILE_ID = MT.RECONCILE_ID and T.TABLE_ID = MT.TABLE_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${REC_ORDER_ID}" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '020'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE with RECONCILE_CODE=020 : ${COUNT}"
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
echo -e "inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${REC_ORDER_ID}" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '020'" >> ${SCRIPT}
echo -e "and R.DIFF_BOO = 'N'" >> ${SCRIPT}
echo -e "and R.LAST_BOO = 'Y'" >> ${SCRIPT}
echo -e "and R.REF_1_RECORD = 1" >> ${SCRIPT}
echo -e "and R.REF_1_AMT = 16" >> ${SCRIPT}
echo -e "and R.REF_1_VALIDITY = 0" >> ${SCRIPT}
echo -e "and R.REF_2_RECORD = 1" >> ${SCRIPT}
echo -e "and R.REF_2_AMT = 16" >> ${SCRIPT}
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
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_BATCH_RECONCILE with RECONCILE_CODE=001,LAST_BOO=Y,DIFF_BOO=N"
echo "      ,REF_1_RECORD=1,REF_1_AMT=16,REF_1_VALIDITY=0"
echo "      ,REF_2_RECORD=1,REF_2_AMT=16,REF_2_VALIDITY=0"
echo "      ,REF_1_L_REF_2_RECORD=0,REF_1_L_REF_2_AMT=0,REF_1_L_REF_2_VALIDITY=0"
echo "      ,REF_1_M_REF_2_RECORD=0,REF_1_M_REF_2_AMT=0,REF_1_M_REF_2_VALIDITY=0 : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

# Cleanup check ORDER

SCRIPT=${WORKING_PATH}/_cleanup.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "\ndelete from PM_INF_PLUGIN_PREPAID_CN_EXCESS_D where ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
echo -e "\ndelete from PM_JOB_ORDER where ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

# Cleanup file

rm ${PLUGIN_TOPUP_OUTPUT_PATH}/${NAME_PART}.sync
rm ${PLUGIN_TOPUP_OUTPUT_PATH}/${NAME_PART}.dat
rm ${PARAM[2]}/${PARAM[0]}
rm ${PARAM[2]}/${PARAM[1]}

return $RET_OK

