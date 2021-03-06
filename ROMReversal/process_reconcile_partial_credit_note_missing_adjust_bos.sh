ORDER_ID=$(cat ${WORKING_PATH}/order_id)

${EXECUTE_PATH}/reconcile -c ${CONFIG_NAME} --order-id ${ORDER_ID} --reconcile-code 014
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
from PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE T
inner join PM_PREPAID_BATCH_RECONCILE_DIFF D on (T.DIFF_ID = D.DIFF_ID)
inner join PM_PREPAID_BATCH_RECONCILE R on (D.BATCH_RCC_ID = R.BATCH_RCC_ID)
inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
inner join PM_JOB_ORDER O on (B.ORDER_ID = O.ORDER_ID)
inner join PM_FILE_CONFIG F on (O.TEMPLATE_CODE = F.TEMPLATE_CODE)
inner join PM_RECONCILE_MAPPING M on (F.FILE_TYPE = M.FILE_TYPE)
inner join PM_RECONCILE_MAPPING_TABLE MT on (M.RECONCILE_ID = MT.RECONCILE_ID and T.TABLE_ID = MT.TABLE_ID)
where B.ORDER_ID = ${ORDER_ID}
and MT.TABLE_NAME = 'PM_BATCH_RVS'
and RM.RECONCILE_CODE = '014'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE with RECONCILE_CODE=014,TABLE_NAME=PM_BATCH_RVS : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
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
where B.ORDER_ID = ${ORDER_ID}
and MT.TABLE_NAME = 'PM_CREDIT_NOTE'
and RM.RECONCILE_CODE = '014'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE with RECONCILE_CODE=014,TABLE_NAME=PM_CREDIT_NOTE : ${COUNT}"
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
where B.ORDER_ID = ${ORDER_ID}
and D.D_MOBILE_NO = '0854000673'
and D.FACE_VALUE = 3.07
and D.TRANS_DTM = '20160615'
and RM.RECONCILE_CODE = '014'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_BATCH_RECONCILE_DIFF with RECONCILE_CODE=014,D_MOBILE_NO=0854000673,FACE_VALUE=3.07,TRANS_DTM=20160615 : ${COUNT}"
if [ "$COUNT" -ne "2" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_PREPAID_BATCH_RECONCILE R
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)
where B.ORDER_ID = ${ORDER_ID}
and RM.RECONCILE_CODE = '014'
and R.DIFF_BOO = 'Y'
and R.LAST_BOO = 'Y'
and R.REF_1_RECORD = 1
and R.REF_1_AMT = 3.07
and R.REF_1_VALIDITY = 0
and R.REF_2_RECORD = 1
and R.REF_2_AMT = 3.07
and R.REF_2_VALIDITY = 0
and R.REF_3_RECORD = 0
and R.REF_3_AMT = 0
and R.REF_3_VALIDITY = 0

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_BATCH_RECONCILE with RECONCILE_CODE=014,LAST_BOO=Y,DIFF_BOO=Y"
echo "      ,REF_1_RECORD=1,REF_1_AMT=3.07,REF_1_VALIDITY=0"
echo "      ,REF_2_RECORD=1,REF_2_AMT=3.07,REF_2_VALIDITY=0"
echo "      ,REF_3_RECORD=0,REF_3_AMT=0,REF_3_VALIDITY=0"
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

exit $RET_OK

