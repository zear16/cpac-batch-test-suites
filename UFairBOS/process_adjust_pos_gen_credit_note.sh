ORDER_ID=$(cat ${WORKING_PATH}/order_id)

# Expected error
${EXECUTE_PATH}/prepaid_loader -c ${CONFIG_NAME} --order-id ${ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_PREPAID_LOAD_BATCH
where ORDER_ID = ${ORDER_ID} and LOAD_TOTAL = 1 and LOAD_SUCCESS = 1 and LOAD_ERROR = 0
and BATCH_STATE = 'L' and PROCESS_STATUS = 'SC'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=L,PROCESS_STATUS=SC
            ,LOAD_TOTAL=1,LOAD_SUCCESS=1,LOAD_ERROR=0 : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

# Expected error
${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_LOAD_PM_BATCH_UFAIR_FROM_INF @order_id=${ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_PREPAID_LOAD_BATCH_REJECT R
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
where B.ORDER_ID = ${ORDER_ID}

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -w200 -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_LOAD_BATCH_REJECT : ${COUNT}"
if [ "$COUNT" -ne "0" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_BATCH_UFAIR U
inner join PM_PREPAID_LOAD_BATCH B on (U.BATCH_ID = B.BATCH_ID)
where B.ORDER_ID = ${ORDER_ID}

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -w200 -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_BATCH_UFAIR : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_PREPAID_LOAD_BATCH
where ORDER_ID = ${ORDER_ID}
and BATCH_STATE = 'C' and PROCESS_STATUS = 'SC'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=C,PROCESS_STATUS=SC : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PM_BATCH_UFAIR_ADJUST @order_id=${ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_PREPAID_LOAD_BATCH
where ORDER_ID = ${ORDER_ID}
and BATCH_STATE = 'A' and PROCESS_STATUS = 'SC'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=A,PROCESS_STATUS=SC : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_FILE_ADJUST
where ORDER_ID = ${ORDER_ID}

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_FILE_ADJUST : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_ADJUST_TRANSACTION T
inner join PM_FILE_ADJUST F on (T.FILE_ID = F.FILE_ID)
where F.ORDER_ID = ${ORDER_ID}
and T.MOBILE_NO = '0910021160' and T.ADJUST_AMT = 100.00 and T.ADJUST_VALIDITY = 10
and T.TRANSPARENT_DATA1 = 'cPAC'
and T.TRANSPARENT_DATA2 = 'UFAIR'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_ADJUST_TRANSACTION with MOBILE_NO=0910021160,ADJUST_AMT=100.00,ADJUST_VALIDITY=10
      , TRANSPARENT_DATA1=cPAC, TRANSPARENT_DATA2=UFAIR : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

# Update FILE_NAME to prevent BSS mockup to process file

echo -e "use PMDB

go

set nocount on

update PM_FILE_ADJUST
set FILE_NAME = 'UnitTest-' || FILE_NAME
where ORDER_ID = ${ORDER_ID}

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

# Expected OK
${EXECUTE_PATH}/adjust -c ${CONFIG_NAME} --order-id=${ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

# Check file

echo -e "use PMDB

go

set nocount on

declare @file_name varchar(200)
select @file_name = FILE_NAME
from PM_FILE_ADJUST
where ORDER_ID = ${ORDER_ID}

print '%1!', @file_name

go
" > ${SCRIPT}
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
echo -e "use PMDB

go

set nocount on

declare @order_id unsigned bigint

insert into PM_JOB_ORDER 
(ORDER_TYPE, TEMPLATE_CODE, JOB_CHAIN, ORDER_MODE, RUN_DATE
, DATA_DATE_FR, DATA_DATE_TO, VERSION_ID
, FILE_NAME, ORIGINAL_FILE_NAME, SOURCE_CTRL_NAME
, FILE_PATH, SOURCE_CTRL_PATH, SOURCE_DATA_PATH
, ORDER_STATUS)
select 'I', max(F.TEMPLATE_CODE), max(M.JOB_CHAIN), 'A', '20160616'
, '20160615', '20160615', max(V.VERSION_ID)
, '${ADJUST_NAME}.chk', '${ADJUST_NAME}.ok', '${ADJUST_NAME}.chk'
, '${OUT_PATH}', '${OUT_PATH}', '${OUT_PATH}'
, 'W'
from PM_FILE_CONFIG_VERSION V
inner join PM_FILE_CONFIG F on (V.FILE_CONFIG_ID = F.FILE_CONFIG_ID)
inner join PM_JOB_SCHEDULER_MAPPING M on (F.TEMPLATE_CODE = M.TEMPLATE_CODE)
where F.TEMPLATE_CODE = 'ADJUST_BY_FILE_CHK'
and V.EFFECTIVE_DATE <= getdate()
and (V.EXPIRY_DATE = null or V.EXPIRY_DATE > getdate())

select @order_id = @@identity

print '%1!', @order_id

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/chk_order_id

CHK_ORDER_ID=($(cat ${WORKING_PATH}/chk_order_id))

# Load Response file
${EXECUTE_PATH}/adjust -c ${CONFIG_NAME} --order-id ${CHK_ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_INF_ADJUST_BALANCE_H I
where I.ORDER_ID = ${CHK_ORDER_ID}

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_INF_ADJUST_BALANCE_H : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_INF_ADJUST_BALANCE_D I
where I.ORDER_ID = ${CHK_ORDER_ID}

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_INF_ADJUST_BALANCE_D : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_INF_ADJUST_BALANCE_T I
where I.ORDER_ID = ${CHK_ORDER_ID}

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_INF_ADJUST_BALANCE_T : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_INF_ADJUST_BALANCE_ERROR_H I
where I.ORDER_ID = ${CHK_ORDER_ID}

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_INF_ADJUST_BALANCE_ERROR_H : ${COUNT}"
if [ "$COUNT" -ne "0" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_INF_ADJUST_BALANCE_ERROR_D I
where I.ORDER_ID = ${CHK_ORDER_ID}

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_INF_ADJUST_BALANCE_ERROR_D : ${COUNT}"
if [ "$COUNT" -ne "0" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_INF_ADJUST_BALANCE_ERROR_T I
where I.ORDER_ID = ${CHK_ORDER_ID}

print '%1!', @count

go
" > ${SCRIPT}
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

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_FILE_ADJUST F
inner join PM_ADJUST_TRANSACTION A on (F.FILE_ID = A.FILE_ID)
where F.ORDER_ID = ${ORDER_ID}
and A.ADJUST_STATUS = 'SC'
and A.BOS_SITE = '1'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_ADJUST_TRANSACTION with ORDER_ID=${ORDER_ID},ADJUST_STATUS=SC,BOS_SITE=1 : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

select A.ADJUST_ID, A.BOS_AMOUNT_ADJUST, A.ADJUST_STATUS, A.RECEIPT_ID
, A.COMPANY_ID, A.SERVICE_ID
, A.LOCATION_CODE
from PM_FILE_ADJUST F
inner join PM_ADJUST_TRANSACTION A on (F.FILE_ID = A.FILE_ID)
where F.ORDER_ID = ${ORDER_ID}

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

# Temporary Configuration Positive Generate Receipt

# Keep old value

echo -e "use PMDB

go

set nocount on

declare @flag char(1)

select @flag = convert(char(1),FIELD1_VALUE)
from PM_SYSTEM_ATTRIBUTE_DTL
where ATTRIBUTE_CODE = 'PREPAID_PARAM'
and DB_VALUE = 'UFAIR_DOC_ADJUST_ADD'

print '%1!', @flag

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/add_flag

ADD_FLAG=$(cat ${WORKING_PATH}/add_flag)

echo -e "use PMDB

go

set nocount on

declare @flag char(1)

select @flag = convert(char(1),FIELD2_VALUE)
from PM_SYSTEM_ATTRIBUTE_DTL
where ATTRIBUTE_CODE = 'PREPAID_PARAM'
and DB_VALUE = 'UFAIR_DOC_ADJUST_ADD'

print '%1!', @flag

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/add_document

ADD_DOCUMENT=$(cat ${WORKING_PATH}/add_document)

echo -e "use PMDB

go

set nocount on

declare @flag char(1)

select @flag = convert(char(1),FIELD1_VALUE)
from PM_SYSTEM_ATTRIBUTE_DTL
where ATTRIBUTE_CODE = 'PREPAID_PARAM'
and DB_VALUE = 'UFAIR_DOC_ADJUST_DEDUCT'

print '%1!', @flag

go

" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/deduct_flag

DEDUCT_FLAG=$(cat ${WORKING_PATH}/deduct_flag)

echo -e "use PMDB\ngo" > ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "\ndeclare @flag char(1)" >> ${SCRIPT}
echo -e "\nselect @flag = convert(char(1),FIELD2_VALUE)" >> ${SCRIPT}
echo -e "from PM_SYSTEM_ATTRIBUTE_DTL" >> ${SCRIPT}
echo -e "where ATTRIBUTE_CODE = 'PREPAID_PARAM'" >> ${SCRIPT}
echo -e "and DB_VALUE = 'UFAIR_DOC_ADJUST_DEDUCT'" >> ${SCRIPT}
echo -e "\nprint '%1!', @flag\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/deduct_document

DEDUCT_DOCUMENT=$(cat ${WORKING_PATH}/deduct_document)

echo -e "use PMDB\ngo" > ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "\nupdate PM_SYSTEM_ATTRIBUTE_DTL set FIELD1_VALUE='Y'" >> ${SCRIPT}
echo -e "where ATTRIBUTE_CODE = 'PREPAID_PARAM'" >> ${SCRIPT}
echo -e "and DB_VALUE = 'UFAIR_DOC_ADJUST_ADD'" >> ${SCRIPT}
echo -e "\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

echo -e "use PMDB\ngo" > ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "\nupdate PM_SYSTEM_ATTRIBUTE_DTL set FIELD2_VALUE='C'" >> ${SCRIPT}
echo -e "where ATTRIBUTE_CODE = 'PREPAID_PARAM'" >> ${SCRIPT}
echo -e "and DB_VALUE = 'UFAIR_DOC_ADJUST_ADD'" >> ${SCRIPT}
echo -e "\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

echo -e "use PMDB\ngo" > ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "\nupdate PM_SYSTEM_ATTRIBUTE_DTL set FIELD1_VALUE='N'" >> ${SCRIPT}
echo -e "where ATTRIBUTE_CODE = 'PREPAID_PARAM'" >> ${SCRIPT}
echo -e "and DB_VALUE = 'UFAIR_DOC_ADJUST_DEDUCT'" >> ${SCRIPT}
echo -e "\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PM_ADJUST_TRANS_GEN_RECEIPT @order_id=${CHK_ORDER_ID}
RET=$?

# Reset Immediately

echo -e "use PMDB\ngo" > ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "\nupdate PM_SYSTEM_ATTRIBUTE_DTL set FIELD1_VALUE='${ADD_FLAG}'" >> ${SCRIPT}
echo -e "where ATTRIBUTE_CODE = 'PREPAID_PARAM'" >> ${SCRIPT}
echo -e "and DB_VALUE = 'UFAIR_DOC_ADJUST_ADD'" >> ${SCRIPT}
echo -e "\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

echo -e "use PMDB\ngo" > ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "\nupdate PM_SYSTEM_ATTRIBUTE_DTL set FIELD2_VALUE='${ADD_DOCUMENT}'" >> ${SCRIPT}
echo -e "where ATTRIBUTE_CODE = 'PREPAID_PARAM'" >> ${SCRIPT}
echo -e "and DB_VALUE = 'UFAIR_DOC_ADJUST_ADD'" >> ${SCRIPT}
echo -e "\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

echo -e "use PMDB\ngo" > ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "\nupdate PM_SYSTEM_ATTRIBUTE_DTL set FIELD1_VALUE='${DEDUCT_FLAG}'" >> ${SCRIPT}
echo -e "where ATTRIBUTE_CODE = 'PREPAID_PARAM'" >> ${SCRIPT}
echo -e "and DB_VALUE = 'UFAIR_DOC_ADJUST_DEDUCT'" >> ${SCRIPT}
echo -e "\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

echo -e "use PMDB\ngo" > ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "\nupdate PM_SYSTEM_ATTRIBUTE_DTL set FIELD1_VALUE='${DEDUCT_DOCUMENT}'" >> ${SCRIPT}
echo -e "where ATTRIBUTE_CODE = 'PREPAID_PARAM'" >> ${SCRIPT}
echo -e "and DB_VALUE = 'UFAIR_DOC_ADJUST_DEDUCT'" >> ${SCRIPT}
echo -e "\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PM_ADJUST_TRANS_SEND_NOTIFICATION @order_id=${CHK_ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB\ngo" > ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "select A.RECEIPT_ID, A.NOTIFICATION_ID" >> ${SCRIPT}
echo -e "from PM_FILE_ADJUST F" >> ${SCRIPT}
echo -e "inner join PM_ADJUST_TRANSACTION A on (F.FILE_ID = A.FILE_ID)" >> ${SCRIPT}
echo -e "where F.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_FILE_ADJUST F
inner join PM_ADJUST_TRANSACTION A on (F.FILE_ID = A.FILE_ID)
inner join PM_ADJUST_TRANSACTION_CREDIT_NOTE AC on (A.ADJUST_ID = AC.ADJUST_ID)
where F.ORDER_ID = ${ORDER_ID}
and A.RECEIPT_ID = null
and A.NOTIFICATION_ID != null

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_ADJUST_TRANSACTION with ORDER_ID=${ORDER_ID}
,RECEIPT_ID=NULL,NOTIFICATION_ID!=NULL 
and PM_ADJUST_TRANSACTION_CREDIT_NOTE : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB\ngo" > ${SCRIPT}
echo -e "select ORDER_ID, TEMPLATE_CODE" >> ${SCRIPT}
echo -e "from PM_JOB_ORDER" >> ${SCRIPT}
echo -e "where REF_ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
echo -e "\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

echo -e "use PMDB\ngo" > ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "\ndeclare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_JOB_ORDER" >> ${SCRIPT}
echo -e "where REF_ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
echo -e "and TEMPLATE_CODE = 'PE_SIEBEL_ACTIVITY_UFAIR'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_JOB_ORDER with REF_ORDER_ID=${CHK_ORDER_ID},TEMPLATE_CODE=PE_SIEBEL_ACTIVITY_UFAIR : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB\ngo" > ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "\ndeclare @order_id unsigned bigint" >> ${SCRIPT}
echo -e "select @order_id = ORDER_ID" >> ${SCRIPT}
echo -e "from PM_JOB_ORDER" >> ${SCRIPT}
echo -e "where REF_ORDER_ID = ${CHK_ORDER_ID}" >> ${SCRIPT}
echo -e "and TEMPLATE_CODE = 'PE_SIEBEL_ACTIVITY_UFAIR'" >> ${SCRIPT}
echo -e "\nprint '%1!', @order_id\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/act_order_id

ACT_ORDER_ID=$(cat ${WORKING_PATH}/act_order_id)

echo -e "use PMDB\ngo" > ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "\ndeclare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_JOB_ORDER_PARAM" >> ${SCRIPT}
echo -e "where ORDER_ID = ${ACT_ORDER_ID}" >> ${SCRIPT}
echo -e "and PARAM_NAME = 'ORIG_ORDER_ID'" >> ${SCRIPT}
echo -e "and PARAM_VALUE = '${ORDER_ID}'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_JOB_ORDER_PARAM with ORDER_ID=${ACT_ORDER_ID},PARAM_NAME=ORIG_ORDER_ID,PARAM_VALUE=${ORDER_ID} : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

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
#echo -e "\ndelete from PM_JOB_ORDER_PARAM where ORDER_ID = ${ACT_ORDER_ID}" >> ${SCRIPT}
#echo -e "\ndelete from PM_JOB_ORDER where ORDER_ID = ${ACT_ORDER_ID}" >> ${SCRIPT}
#echo -e "\ngo" >> ${SCRIPT}

#isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

cp ${WORKING_PATH}/chk_order_id ${WORKING_PATH}/order_id

exit $RET_OK

