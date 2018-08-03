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

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_LOAD_PM_BATCH_CAMPAIGN_FROM_INF @order_id=${ORDER_ID}
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
echo -e "from PM_PREPAID_LOAD_BATCH_REJECT R"  >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -w200 -i ${SCRIPT} > ${WORKING_PATH}/count

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
echo -e "from PM_BATCH_CAMPAIGN U"  >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (U.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -w200 -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_BATCH_UFAIR : ${COUNT}"

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
echo -e "and BATCH_STATE = 'C' and PROCESS_STATUS = 'SC'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=C,PROCESS_STATUS=SC : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PM_BATCH_CAMPAIGN_ADJUST @order_id=${ORDER_ID}
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
echo -e "and T.MOBILE_NO = '0819017657' and T.ADJUST_AMT = 100.00 and T.ADJUST_VALIDITY = 10" >> ${SCRIPT}
echo -e "and T.TRANSPARENT_DATA1 = 'cPAC'" >> ${SCRIPT}
echo -e "and T.TRANSPARENT_DATA2 = 'CAMPAIGN'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_ADJUST_TRANSACTION with MOBILE_NO=0819017657,ADJUST_AMT=100.00,ADJUST_VALIDITY=10"
echo "      , TRANSPARENT_DATA1=cPAC, TRANSPARENT_DATA2=CAMPAIGN : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

# Update FILE_NAME to prevent BSS mockup to process file

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "\nupdate PM_FILE_ADJUST" >> ${SCRIPT}
echo -e "set FILE_NAME = 'UnitTest-' || FILE_NAME" >> ${SCRIPT}
echo -e "where ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

# Expected OK
${EXECUTE_PATH}/adjust -c ${CONFIG_NAME} --order-id=${ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

# Check file

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @file_name varchar(200)" >> ${SCRIPT}
echo -e "select @file_name = FILE_NAME" >> ${SCRIPT}
echo -e "from PM_FILE_ADJUST"  >> ${SCRIPT}
echo -e "where ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @file_name" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/adjust_file

ADJUST_FILE=$(cat ${WORKING_PATH}/adjust_file)
IN_PATH=/export/home/MNT_NFS/bos1/BSSBroker/input/AdjustBalance

echo "check file ${IN_PATH}/${ADJUST_FILE}"
if [ -f "${IN_PATH}/${ADJUST_FILE}" ]; then
  echo -e "found ${IN_PATH}/${ADJUST_FILE}"
else
  exit $RET_FAIL
fi

ADJUST_NAME=${ADJUST_FILE:0:38}
OUT_PATH=/export/home/MNT_NFS/bos1/BSSBroker/output/AdjustBalance

HEADER=$(head -n 1 ${IN_PATH}/${ADJUST_FILE})
HEADER=${HEADER:0:18}
echo "${HEADER}" > ${OUT_PATH}/${ADJUST_NAME}.ok
DATA=$(sed '2q;d' ${IN_PATH}/${ADJUST_FILE})
BODY_CODE="${DATA:0:2}"
BODY=${DATA:2}
BODY=${BODY%|*}
BODY=${BODY%|*}
BODY=${BODY%|*}
DATA="${BODY_CODE}|1000000|"
i=0
oIFS=$IFS
IFS='|' read -ra ARR <<< "${BODY}"
for field in "${ARR[@]}"; do
  if  (( $i > 0 && $i < 14 )); then
    DATA="$DATA|${field}"
  fi
  let "i += 1"
done
IFS=$oIFS
DATA="${DATA}|1"
echo "${DATA}" >> ${OUT_PATH}/${ADJUST_NAME}.ok
tail -n 1 ${IN_PATH}/${ADJUST_FILE} >> ${OUT_PATH}/${ADJUST_NAME}.ok

# Make check file
echo "Success=1,Fail=0" > ${OUT_PATH}/${ADJUST_NAME}.chk

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
echo -e ", '${ADJUST_NAME}.chk', '${ADJUST_NAME}.ok', '${ADJUST_NAME}.chk'" >> ${SCRIPT}
echo -e ", '${OUT_PATH}', '${OUT_PATH}', '${OUT_PATH}'" >> ${SCRIPT}
echo -e ", 'W'" >> ${SCRIPT}
echo -e "from PM_FILE_CONFIG_VERSION V" >> ${SCRIPT}
echo -e "inner join PM_FILE_CONFIG F on (V.FILE_CONFIG_ID = F.FILE_CONFIG_ID)" >> ${SCRIPT}
echo -e "inner join PM_JOB_SCHEDULER_MAPPING M on (F.TEMPLATE_CODE = M.TEMPLATE_CODE)" >> ${SCRIPT}
echo -e "where F.TEMPLATE_CODE = 'ADJUST_BY_FILE_CHK'" >> ${SCRIPT}
echo -e "and V.EFFECTIVE_DATE <= getdate()" >> ${SCRIPT}
echo -e "and (V.EXPIRY_DATE = null or V.EXPIRY_DATE > getdate())" >> ${SCRIPT}
echo -e "\nselect @order_id = @@identity" >> ${SCRIPT}
echo -e "\nprint '%1!', @order_id" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/chk_order_id

CHK_ORDER_ID=($(cat ${WORKING_PATH}/chk_order_id))

# Load Response file
${EXECUTE_PATH}/adjust -c ${CONFIG_NAME} --order-id ${CHK_ORDER_ID}
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
echo -e "from PM_INF_ADJUST_BALANCE_H I"  >> ${SCRIPT}
echo -e "where I.ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_INF_ADJUST_BALANCE_H : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_INF_ADJUST_BALANCE_D I"  >> ${SCRIPT}
echo -e "where I.ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_INF_ADJUST_BALANCE_D : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_INF_ADJUST_BALANCE_T I"  >> ${SCRIPT}
echo -e "where I.ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_INF_ADJUST_BALANCE_T : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_INF_ADJUST_BALANCE_ERROR_H I"  >> ${SCRIPT}
echo -e "where I.ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_INF_ADJUST_BALANCE_ERROR_H : ${COUNT}"

if [ "$COUNT" -ne "0" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_INF_ADJUST_BALANCE_ERROR_D I"  >> ${SCRIPT}
echo -e "where I.ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_INF_ADJUST_BALANCE_ERROR_D : ${COUNT}"

if [ "$COUNT" -ne "0" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_INF_ADJUST_BALANCE_ERROR_T I"  >> ${SCRIPT}
echo -e "where I.ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_INF_ADJUST_BALANCE_ERROR_T : ${COUNT}"

if [ "$COUNT" -ne "0" ]; then
  exit $RET_FAIL
fi

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_LOAD_PM_ADJUST_TRANS_FROM_INF @order_id=${CHK_ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB\ngo" > ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "\ndeclare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_FILE_ADJUST F" >> ${SCRIPT}
echo -e "inner join PM_ADJUST_TRANSACTION A on (F.FILE_ID = A.FILE_ID)" >> ${SCRIPT}
echo -e "where F.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and A.ADJUST_STATUS = 'SC'" >> ${SCRIPT}
echo -e "and A.BOS_SITE = '1'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_ADJUST_TRANSACTION with ORDER_ID=${ORDER_ID},ADJUST_STATUS=SC,BOS_SITE=1 : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB\ngo" > ${SCRIPT}
echo -e "select A.ADJUST_ID, A.BOS_AMOUNT_ADJUST, A.ADJUST_STATUS, A.RECEIPT_ID" >> ${SCRIPT}
echo -e ", A.COMPANY_ID, A.SERVICE_ID" >> ${SCRIPT}
echo -e ", A.LOCATION_CODE" >> ${SCRIPT}
echo -e "from PM_FILE_ADJUST F" >> ${SCRIPT}
echo -e "inner join PM_ADJUST_TRANSACTION A on (F.FILE_ID = A.FILE_ID)" >> ${SCRIPT}
echo -e "where F.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PM_ADJUST_TRANS_GEN_RECEIPT @order_id=${CHK_ORDER_ID}
RET=$?

echo -e "use PMDB\ngo" > ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "select A.RECEIPT_ID, A.NOTIFICATION_ID" >> ${SCRIPT}
echo -e "from PM_FILE_ADJUST F" >> ${SCRIPT}
echo -e "inner join PM_ADJUST_TRANSACTION A on (F.FILE_ID = A.FILE_ID)" >> ${SCRIPT}
echo -e "where F.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

echo -e "use PMDB\ngo" > ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "\ndeclare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_FILE_ADJUST F" >> ${SCRIPT}
echo -e "inner join PM_ADJUST_TRANSACTION A on (F.FILE_ID = A.FILE_ID)" >> ${SCRIPT}
echo -e "where F.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and A.RECEIPT_ID = null" >> ${SCRIPT}
echo -e "and A.NOTIFICATION_ID = null" >> ${SCRIPT}
echo -e "\nprint '%1!', @count\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_ADJUST_TRANSACTION with ORDER_ID=${ORDER_ID},RECEIPT_ID=NULL,NOTIFICATION_ID=NULL : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PM_ADJUST_TRANS_SEND_NOTIFICATION @order_id=${CHK_ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB\ngo" > ${SCRIPT}
echo -e "select ORDER_ID, TEMPLATE_CODE" >> ${SCRIPT}
echo -e "from PM_JOB_ORDER" >> ${SCRIPT}
echo -e "where REF_ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
echo -e "\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

# Cleanup check ORDER

#SCRIPT=${WORKING_PATH}/_cleanup.sql
#echo -e "use PMDB" > ${SCRIPT}
#echo -e "\ngo" >> ${SCRIPT}
#echo -e "\nset nocount on" >> ${SCRIPT}
#echo -e "\ndelete from PM_INF_ADJUST_BALANCE_H where ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
#echo -e "\ndelete from PM_INF_ADJUST_BALANCE_D where ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
#echo -e "\ndelete from PM_INF_ADJUST_BALANCE_B where ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
#echo -e "\ndelete from PM_INF_ADJUST_BALANCE_T where ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
#echo -e "\ndelete from PM_INF_ADJUST_BALANCE_ERROR_H where ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
#echo -e "\ndelete from PM_INF_ADJUST_BALANCE_ERROR_D where ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
#echo -e "\ndelete from PM_INF_ADJUST_BALANCE_ERROR_T where ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
#echo -e "\ndelete from PM_JOB_ORDER where ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
#echo -e "\ngo" >> ${SCRIPT}

#isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

cp ${WORKING_PATH}/chk_order_id ${WORKING_PATH}/order_id

exit $RET_OK

