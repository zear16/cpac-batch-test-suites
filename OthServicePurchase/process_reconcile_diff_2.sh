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

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PM_BATCH_DCB_GEN_RECEIPT @order_id=${ORDER_ID}
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
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=G,PROCESS_STATUS=SC : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

${EXECUTE_PATH}/reconcile -c ${CONFIG_NAME} --order-id ${RECONCILE_ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE T
inner join PM_PREPAID_BATCH_RECONCILE_DIFF D on (T.DIFF_ID = D.DIFF_ID)
inner join PM_PREPAID_BATCH_RECONCILE R on (D.BATCH_RCC_ID = R.BATCH_RCC_ID)
inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
inner join PM_JOB_ORDER O on (B.ORDER_ID = O.ORDER_ID)
inner join PM_FILE_CONFIG F on (O.TEMPLATE_CODE = F.TEMPLATE_CODE)
inner join PM_RECONCILE_MAPPING M on (F.FILE_TYPE = M.FILE_TYPE)
inner join PM_RECONCILE_MAPPING_TABLE MT on (M.RECONCILE_ID = MT.RECONCILE_ID and T.TABLE_ID = MT.TABLE_ID)
where B.ORDER_ID = ${RECONCILE_ORDER_ID}
and MT.TABLE_NAME = 'PM_CREDIT_NOTE'
and RM.RECONCILE_CODE = '002'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE with RECONCILE_CODE=002,TABLE_NAME=PM_CREDIT_NOTE : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_PREPAID_BATCH_RECONCILE_DIFF D
inner join PM_PREPAID_BATCH_RECONCILE R on (D.BATCH_RCC_ID = R.BATCH_RCC_ID)
inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
where B.ORDER_ID = ${RECONCILE_ORDER_ID}
and D.D_MOBILE_NO = '0817037536'
and D.TRANS_DTM = '20160616'
and D.FACE_VALUE = 101
and D.VALIDITY = null
and RM.RECONCILE_CODE = '002'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_BATCH_RECONCILE_DIFF with RECONCILE_CODE=002,D_MOBILE_NO=0817037536,TRANS_DTM=20160616,FACE_VALUE=101,VALIDITY=null : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB

go

set nocount on

select R.REF_1_RECORD, R.REF_1_AMT, R.REF_1_VALIDITY
, R.REF_2_RECORD, R.REF_2_AMT, R.REF_2_VALIDITY
, R.REF_1_L_REF_2_RECORD, R.REF_1_L_REF_2_AMT, R.REF_1_L_REF_2_VALIDITY
, R.REF_1_M_REF_2_RECORD, R.REF_1_M_REF_2_AMT, R.REF_1_M_REF_2_VALIDITY
from PM_PREPAID_BATCH_RECONCILE R
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)
where B.ORDER_ID = ${RECONCILE_ORDER_ID}
and RM.RECONCILE_CODE = '002'

go
" > ${SCRIPT}
#isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_PREPAID_BATCH_RECONCILE R
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)
where B.ORDER_ID = ${RECONCILE_ORDER_ID}
and RM.RECONCILE_CODE = '002'
and R.DIFF_BOO = 'Y'
and R.LAST_BOO = 'Y'
and R.REF_1_RECORD = 1
and R.REF_1_AMT = 100
and R.REF_1_VALIDITY = 0
and R.REF_2_RECORD = 2
and R.REF_2_AMT = 201
and R.REF_2_VALIDITY = 0
and R.REF_1_L_REF_2_RECORD = 0
and R.REF_1_L_REF_2_AMT = 0
and R.REF_1_L_REF_2_VALIDITY = 0
and R.REF_1_M_REF_2_RECORD = 1
and R.REF_1_M_REF_2_AMT = 101
and R.REF_1_M_REF_2_VALIDITY = 0

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_BATCH_RECONCILE with RECONCILE_CODE=002,LAST_BOO=Y,DIFF_BOO=Y"
echo "      ,REF_1_RECORD=1,REF_1_AMT=100,REF_1_VALIDITY=0"
echo "      ,REF_2_RECORD=2,REF_2_AMT=201,REF_2_VALIDITY=0"
echo "      ,REF_1_L_REF_2_RECORD=0,REF_1_L_REF_2_AMT=0,REF_1_L_REF_2_VALIDITY=0"
echo "      ,REF_1_M_REF_2_RECORD=1,REF_1_M_REF_2_AMT=101,REF_1_M_REF_2_VALIDITY=0 : ${COUNT}"
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
where B.ORDER_ID = ${RECONCILE_ORDER_ID}

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
echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_PREPAID_LOAD_BATCH
where ORDER_ID = ${RECONCILE_ORDER_ID}
and BATCH_STATE = 'R'
and PROCESS_STATUS = 'SC'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=R,PROCESS_STATUS=SC : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

cp ${WORKING_PATH}/reconcile_order_id ${WORKING_PATH}/order_id

exit $RET_OK
