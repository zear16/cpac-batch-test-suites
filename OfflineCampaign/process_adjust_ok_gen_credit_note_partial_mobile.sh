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

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_LOAD_PM_BATCH_CAMPAIGN_FROM_INF @order_id=${ORDER_ID}
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
from PM_BATCH_CAMPAIGN U
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

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PM_BATCH_CAMPAIGN_ADJUST @order_id=${ORDER_ID}
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
and T.MOBILE_NO = '0819017657' and T.ADJUST_AMT = 100.00 and T.ADJUST_VALIDITY = 10
and T.TRANSPARENT_DATA1 = 'cPAC'
and T.TRANSPARENT_DATA2 = 'CAMPAIGN'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_ADJUST_TRANSACTION with MOBILE_NO=0819017657,ADJUST_AMT=100.00,ADJUST_VALIDITY=10
      , TRANSPARENT_DATA1=cPAC, TRANSPARENT_DATA2=CAMPAIGN : ${COUNT}"
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
  echo "found ${IN_PATH}/${ADJUST_FILE}"
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

# Temporary inset PM_CAMPAIGN_PROJECT to Generate Receipt
echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*) from PM_CAMPAIGN_PROJECT where PROJECT_CODE = 'Cash Back'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
if [ "$COUNT" = "0" ]; then
  echo -e "use PMDB

go

set nocount on

insert into PM_CAMPAIGN_PROJECT
(PROJECT_CODE, BANK_CODE, SERVICE_ID, ACTIVE_BOO
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
('Cash Back', 1902, 900, 'Y'
, 'unit', getdate(), 'unit', getdate())

go
  " > ${SCRIPT}
  isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}
fi

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PM_ADJUST_TRANS_GEN_RECEIPT @order_id=${CHK_ORDER_ID}
RET=$?

# Delete immediately

if [ "${COUNT}" -ne "0" ]; then
  echo -e "use PMDB

go

set nocount on

delete from PM_CAMPAIGN_PROJECT where PROJECT_CODE = 'Cash Back'

go
  " > ${SCRIPT}
  isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}
fi

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
and A.NOTIFICATION_ID = null
print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_ADJUST_TRANSACTION_CREDIT_NOTE : ${COUNT}"
if [ "$COUNT" -ne "2" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

select AD.MOBILE_NO as AD_MOBILE_NO, AD.BILLING_SYSTEM, AD.ADJUST_AMT, AD.ADJUST_STATUS
, CN.CN_NO, PMDB..PM_F_FORMAT_DATE(CN.CN_DATE, 'YYYY-MM-DD') as CN_DATE
, CN.REFUND_TOTAL_AMT, CN.MOBILE_NO, CD.REFUND_TOTAL_AMT, CN.REF_DOC_TYPE
from PMDB..PM_ADJUST_TRANSACTION AD 
inner join PMDB..PM_ADJUST_TRANSACTION_CREDIT_NOTE ADC on (AD.ADJUST_ID = ADC.ADJUST_ID) 
inner join PMDB..PM_FILE_ADJUST FL on (AD.FILE_ID = FL.FILE_ID) 
inner join PMDB..PM_ADJUST_TRANSACTION I on (FL.FILE_ID = I.FILE_ID) 
inner join PMDB..PM_INF_ADJUST_BALANCE_D INF on (I.SO_NBR = INF.SO_NBR and INF.ORDER_LINE_NO = 1) 
left join PMDB..PM_CREDIT_NOTE CN on (ADC.CN_ID = CN.CN_ID and ADC.CN_DATE = CN.CN_DATE) 
left join PMDB..PM_COMPANY CR on (CN.COMPANY_ID = CR.COMPANY_ID) 
left join PMDB..PM_PAYMENT_CATEGORY CT on (CN.CATEGORY_CODE = CT.CATEGORY_CODE) 
left join PMDB..PM_CREDIT_NOTE_DTL CD on (CN.CN_ID= CD.CN_ID and CN.CN_DATE = CD.CN_DATE) 
left join PMDB..PM_BUSINESS_OF_PAYMENT BOP on (CN.BOP_ID = BOP.BOP_ID) 
where INF.ORDER_ID = ${CHK_ORDER_ID}

go
" > ${SCRIPT}
#isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} -Jutf8 -w200

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_ADJUST_TRANSACTION AD
inner join PM_ADJUST_TRANSACTION_CREDIT_NOTE ADC on (AD.ADJUST_ID = ADC.ADJUST_ID)
inner join PM_FILE_ADJUST FL on (AD.FILE_ID = FL.FILE_ID)
inner join PM_CREDIT_NOTE C on (ADC.CN_ID = C.CN_ID and ADC.CN_DATE = C.CN_DATE)
where FL.ORDER_ID = ${ORDER_ID}
and C.REF_DOC_TYPE = 'RE'
and C.REFUND_TOTAL_AMT = 40

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_CREDIT_NOTE with REF_DOC_TYPE=RE,REFUND_TOTAL_AMT=40 : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_ADJUST_TRANSACTION AD
inner join PM_ADJUST_TRANSACTION_CREDIT_NOTE ADC on (AD.ADJUST_ID = ADC.ADJUST_ID)
inner join PM_FILE_ADJUST FL on (AD.FILE_ID = FL.FILE_ID)
inner join PM_CREDIT_NOTE C on (ADC.CN_ID = C.CN_ID and ADC.CN_DATE = C.CN_DATE)
where FL.ORDER_ID = ${ORDER_ID}
and C.REF_DOC_TYPE = 'MO'
and C.REFUND_TOTAL_AMT = 60

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_CREDIT_NOTE with REF_DOC_TYPE=MO,REFUND_TOTAL_AMT=60 : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PM_ADJUST_TRANS_SEND_NOTIFICATION @order_id=${CHK_ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

select ORDER_ID, TEMPLATE_CODE
from PM_JOB_ORDER
where REF_ORDER_ID = ${CHK_ORDER_ID}

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

# Cleanup check ORDER

#echo -e "use PMDB
#go
#set nocount on
#delete from PM_INF_ADJUST_BALANCE_H where ORDER_ID = ${CHK_ORDER_ID}
#delete from PM_INF_ADJUST_BALANCE_D where ORDER_ID = ${CHK_ORDER_ID}
#delete from PM_INF_ADJUST_BALANCE_B where ORDER_ID = ${CHK_ORDER_ID}
#delete from PM_INF_ADJUST_BALANCE_T where ORDER_ID = ${CHK_ORDER_ID}
#delete from PM_INF_ADJUST_BALANCE_ERROR_H where ORDER_ID = ${CHK_ORDER_ID}
#delete from PM_INF_ADJUST_BALANCE_ERROR_D where ORDER_ID = ${CHK_ORDER_ID}
#delete from PM_INF_ADJUST_BALANCE_ERROR_T where ORDER_ID = ${CHK_ORDER_ID}
#delete from PM_JOB_ORDER where ORDER_ID = ${CHK_ORDER_ID}
#go" > ${SCRIPT}
#isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

cp ${WORKING_PATH}/chk_order_id ${WORKING_PATH}/order_id

exit $RET_OK

