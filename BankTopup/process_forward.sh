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
where ORDER_ID = ${ORDER_ID}
and BATCH_STATE = 'L' and PROCESS_STATUS = 'SC'
and LOAD_TOTAL = 1 and LOAD_SUCCESS = 1 and LOAD_ERROR = 0

print '%1!', @count

go" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=L,PROCESS_STATUS=SC,LOAD_TOTAL=2,LOAD_SUCCESS=2,LOAD_ERROR=0 : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_LOAD_PM_BATCH_BANK_TOPUP_FROM_INF @order_id=${ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

echo -e "
use PMDB

go

select R.SEQ_NO, R.REMARK
from PM_PREPAID_LOAD_BATCH_REJECT R
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
where B.ORDER_ID = ${ORDER_ID}

go
" > ${SCRIPT}
#isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

echo -e "
use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_PREPAID_LOAD_BATCH_REJECT R
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
where B.ORDER_ID = ${ORDER_ID}
and R.SEQ_NO = 2
and R.REMARK = 'NOT_PREPAID_DATA'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_LOAD_BATCH_REJECT with SEQ_NO=2,REMARK='NOT_PREPAID_DATA' : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

${EXECUTE_PATH}/forward -c ${CONFIG_NAME} --order-id ${ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

echo -e "
use PMDB

go

set nocount on

declare @forward_file varchar(200)

select @forward_file = V.FORWARD_PATH + '/' + J.FILE_NAME
from PM_JOB_ORDER J
inner join PM_FILE_CONFIG_VERSION V on (J.VERSION_ID = V.VERSION_ID)
where J.ORDER_ID = ${ORDER_ID}

print '%1!', @forward_file

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/forward
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

FORWARD=$(cat ${WORKING_PATH}/forward)
if [ ! -f "${FORWARD}" ]; then
  echo "file '${FORWARD}' not found"
  exit $RET_FAIL
fi

diff ${FORWARD} ${WORKING_PATH}/forward_cmp.file
DIFF=$(diff ${FORWARD} ${WORKING_PATH}/forward_cmp.file)
if [ "${DIFF}" != "" ]; then
  exit $RET_FAIL
fi

exit $RET_OK

