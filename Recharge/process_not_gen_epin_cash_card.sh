ORDER_ID=$(cat ${WORKING_PATH}/order_id)

# Save Old value for ServiceId 902 (ePin)

SERVICE_ID=902

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB

go

set nocount on

declare @flag char(1)

select @flag = RECHARGE_BOO from PM_RECHARGE_SERVICE where SERVICE_ID = ${SERVICE_ID}

print '%1!', @flag

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/save_recharge_boo
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
SAVE_RECHARGE_BOO=$(cat ${WORKING_PATH}/save_recharge_boo)

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB

go

set nocount on

declare @flag char(1)

select @flag = GEN_RECEIPT_BOO from PM_RECHARGE_SERVICE where SERVICE_ID = ${SERVICE_ID}

print '%1!', @flag

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/save_gen_receipt_boo
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
SAVE_GEN_RECEIPT_BOO=$(cat ${WORKING_PATH}/save_gen_receipt_boo)

# Update ServiceId 902 (ePin) to 'Y' to test this case

echo -e "use PMDB

go

set nocount on

update PM_RECHARGE_SERVICE 
set RECHARGE_BOO = 'Y' 
, GEN_RECEIPT_BOO = 'Y'
where SERVICE_ID = ${SERVICE_ID}

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

# Expected OK
${EXECUTE_PATH}/recharge -c ${CONFIG_NAME} --order-id ${ORDER_ID}
RET=$?

# Ignore error
echo -e "use PMDB

go

set nocount on

update PM_RECHARGE_SERVICE 
set RECHARGE_BOO = '${SAVE_RECHARGE_BOO}'
, GEN_RECEIPT_BOO = '${SAVE_GEN_RECEIPT_BOO}'
where SERVICE_ID = ${SERVICE_ID}

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

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
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
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
from PM_RECHARGE R
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
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
echo "found PM_RECHARGE : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

# Update ServiceId 902 (ePin) to 'Y' to test this case

echo -e "use PMDB

go

set nocount on

update PM_RECHARGE_SERVICE 
set RECHARGE_BOO = 'Y' 
, GEN_RECEIPT_BOO = 'Y'
where SERVICE_ID = ${SERVICE_ID}

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PM_RECHARGE_GEN_RECEIPT @order_id=${ORDER_ID}
RET=$?

# Restore ServiceId 902 (ePin) to old value immediately

# Ignore error
echo -e "use PMDB

go

set nocount on

update PM_RECHARGE_SERVICE 
set RECHARGE_BOO = '${SAVE_RECHARGE_BOO}'
, GEN_RECEIPT_BOO = '${SAVE_GEN_RECEIPT_BOO}'
where SERVICE_ID = ${SERVICE_ID}

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_RECHARGE R
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
where B.ORDER_ID = ${ORDER_ID}
and R.RECEIPT_NO = null

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_RECHARGE with RECEIPT_NO=null : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_CASH_CARD_RECEIPT C
where C.CARD_BATCH_ID = '16001'
and C.CARD_SERIAL_NO = '10'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_CASH_CARD_RECEIPT with CARD_BATCH_ID=16001, CARD_SERIAL_NO=10  : ${COUNT}"
if [ "$COUNT" -ne "0" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_RECHARGE_GEN_RECEIPT_STATE S
inner join PM_PREPAID_LOAD_BATCH B on (S.BATCH_ID = B.BATCH_ID)
where B.ORDER_ID = ${ORDER_ID}
and S.CUR_NO = S.MAX_NO

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_RECHARGE_GEN_RECEIPT with CUR_NO=MAX_NO : ${COUNT}"
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
and BATCH_STATE = 'G' and PROCESS_STATUS = 'SC'

print '%1!', @count

go
" > ${SCRIPT}
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

exit $RET_OK

