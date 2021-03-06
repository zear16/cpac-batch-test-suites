ORDER_ID=$(cat ${WORKING_PATH}/order_id)

# Expected OK
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
from PM_INF_BATCH_DCB I
where I.ORDER_ID = ${ORDER_ID}

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_INF_BATCH_DCB : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_LOAD_PM_BATCH_DCB_FROM_INF @order_id=${ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_BATCH_DCB B
inner join PM_PREPAID_LOAD_BATCH L on (B.BATCH_ID = L.BATCH_ID)
where L.ORDER_ID = ${ORDER_ID}
and B.RECORD_STATUS = 'SC'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_BATCH_DCB with RECORD_STATUS=SC : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

RECONCILE_ORDER_ID=$(cat ${WORKING_PATH}/reconcile_order_id)

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PM_BATCH_DCB_GEN_RECEIPT @order_id=${RECONCILE_ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_BATCH_DCB B
inner join PM_PREPAID_LOAD_BATCH L on (B.BATCH_ID = L.BATCH_ID)
inner join PM_BATCH_DCB_CREDIT_NOTE BC on (B.DCB_ID = BC.DCB_ID)
where L.ORDER_ID = ${ORDER_ID}

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_BATCH_DCB_CREDIT_NOTE : ${COUNT}"
if [ "$COUNT" -ne "2" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_PREPAID_LOAD_BATCH
where ORDER_ID = ${RECONCILE_ORDER_ID}
and BATCH_STATE = 'G' and PROCESS_STATUS = 'SC'

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
