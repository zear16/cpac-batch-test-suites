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

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_LOAD_BATCH with LOAD_TOTAL=1,LOAD_SUCCESS=1,LOAD_ERROR=0 : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
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
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
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
from PM_INF_BATCH_HT
where ORDER_ID = ${ORDER_ID}

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_INF_BATCH_HT : ${COUNT}"
if [ "$COUNT" -ne "2" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_INF_BATCH_RVS_D
where ORDER_ID = ${ORDER_ID}

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_INF_BATCH_RVS_D : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_LOAD_PM_BATCH_RVS_FROM_INF @order_id=${ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_BATCH_RVS R
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
where B.ORDER_ID = ${ORDER_ID}

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_BATCH_RVS  : ${COUNT}"
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
and BATCH_STATE = 'C'
and PROCESS_STATUS = 'SC'

print '%1!', @count

go
" > ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=C,PROCESS_STATUS=SC : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PM_BATCH_RVS_GEN_CREDIT_NOTE @order_id=${ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_BATCH_RVS R
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
inner join PM_BATCH_RVS_CREDIT_NOTE RC on (R.RVS_ID = RC.RVS_ID)
where B.ORDER_ID = ${ORDER_ID}
and R.CN_ID = null and R.CN_DATE = null

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_BATCH_RVS_CREDIT_NOTE : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_BATCH_RVS R
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
inner join PM_BATCH_RVS_CREDIT_NOTE RC on (R.RVS_ID = RC.RVS_ID)
inner join PM_CREDIT_NOTE C on (RC.CN_ID = C.CN_ID)
where B.ORDER_ID = ${ORDER_ID}
and C.CN_DATE = '20170616'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_CREDIT_NOTE : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

select CN.CN_NO, CN.CN_DATE, CN.REF_DOC_TYPE, CN.REFUND_TOTAL_AMT
, CD.CN_DTL_ID, CD.REFUND_TOTAL_AMT, BOP.BOP_CODE, CT.CATEGORY_ABBR
, convert(varchar(5),SBOP.SUB_BOP_CODE)
from PMDB..PM_BATCH_RVS B
inner join PMDB..PM_BATCH_RVS_CREDIT_NOTE BRC on (B.RVS_ID = BRC.RVS_ID)
inner join PMDB..PM_PREPAID_LOAD_BATCH L on (B.BATCH_ID = L.BATCH_ID)
inner join PMDB..PM_CREDIT_NOTE CN on (BRC.CN_ID = CN.CN_ID and BRC.CN_DATE = CN.CN_DATE)
inner join PMDB..PM_CREDIT_NOTE_DTL CD on (CN.CN_ID = CD.CN_ID and CN.CN_DATE = CD.CN_DATE)
left join PMDB..PM_BUSINESS_OF_PAYMENT BOP on (CN.BOP_ID = BOP.BOP_ID)
left join PMDB..PM_PAYMENT_CATEGORY CT on (CN.CATEGORY_CODE = CT.CATEGORY_CODE)
left join PMDB..PM_SUB_BUSINESS_OF_PAYMENT SBOP on (CD.SUB_BOP_ID = SBOP.SUB_BOP_ID)
where L.ORDER_ID = ${ORDER_ID}

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} -Jutf8 -w200

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_PREPAID_LOAD_BATCH
where ORDER_ID = ${ORDER_ID}
and BATCH_STATE = 'G'
and PROCESS_STATUS = 'SC'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=G,PROCESS_STATUS=SC : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

exit $RET_OK

