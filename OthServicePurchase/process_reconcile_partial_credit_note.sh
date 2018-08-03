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

select DATA_DATE_FR, DATA_DATE_TO
from PM_JOB_ORDER
where ORDER_ID = ${ORDER_ID}

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} -Jutf8 -w200

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

echo -e "${RECONCILE_ORDER_ID}"

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

echo -e "use PMDB

go

set nocount on

declare @data_date    date
declare @category_code unsigned bigint
declare @sub_bop_id    unsigned bigint

select @data_date = J.DATA_DATE_FR, @category_code = C.CATEGORY_CODE
from PM_JOB_ORDER J, PM_PAYMENT_CATEGORY C
where J.ORDER_ID = ${RECONCILE_ORDER_ID}
and C.CATEGORY_ABBR = 'MP'

select @sub_bop_id = SUB_BOP_ID from PM_SUB_BUSINESS_OF_PAYMENT where SUB_BOP_CODE = 'PU'

print '@data_date=[%1!],@category_code=[%2!],@sub_bop_id=[%3!]'
, @data_date, @category_code, @sub_bop_id

select D.DCB_ID, D.BANK_CODE, D.MOBILE_NO
, convert(varchar(8), convert(date, D.START_TIME), 112) as START_TIME, D.PARTIAL_FEE 
from PM_BATCH_DCB D 
inner join PM_PREPAID_LOAD_BATCH B on (D.BATCH_ID = B.BATCH_ID) 
inner join PM_JOB_ORDER J on (B.ORDER_ID = J.ORDER_ID) 
where B.FILE_TYPE = 'PE_OTH_SERV_PURCHASE' 
and J.DATA_DATE_FR = @data_date 
and D.SERVICE_PACKAGE_ID in ('5', '7') 
and D.CATEGORY_ID = '300' 
and convert(decimal(14,2), D.PARTIAL_FEE) > 0.0 
and D.END_CAUSE = '000' 
order by BANK_CODE, MOBILE_NO, START_TIME, PARTIAL_FEE, DCB_ID

--select DC.CN_ID, DC.CN_DATE
--from PM_BATCH_DCB_CREDIT_NOTE DC
--inner join PM_BATCH_DCB D on (DC.DCB_ID = D.DCB_ID)
--inner join PM_PREPAID_LOAD_BATCH L on (D.BATCH_ID = L.BATCH_ID)
--where L.ORDER_ID = ${ORDER_ID}

select null as CN_ID, C.MOBILE_NO, convert(varchar(8), C.CN_DATE, 112) as CN_DATE
, sum(C.REFUND_TOTAL_AMT) as REFUND_TOTAL_AMT, C.BANK_CODE, null as CN_NO, DCB.DCB_ID
from PM_CREDIT_NOTE C
inner join PM_BATCH_DCB_CREDIT_NOTE BC on (C.CN_ID = BC.CN_ID and BC.CN_DATE = C.CN_DATE)
inner join PM_BATCH_DCB DCB on (BC.DCB_ID = DCB.DCB_ID)
where C.CN_DATE = @data_date  
and C.CATEGORY_CODE = @category_code  
group by C.MOBILE_NO, convert(varchar(8), C.CN_DATE, 112), C.BANK_CODE, DCB.DCB_ID 
--union all 

select C.CN_ID, C.MOBILE_NO, convert(varchar(8), C.CN_DATE, 112) as CN_DATE
, C.REFUND_TOTAL_AMT, C.BANK_CODE , C.CN_NO, null as DCB_ID 
from PM_CREDIT_NOTE C 
inner join PM_CREDIT_NOTE_DTL CD on (C.CN_ID = CD.CN_ID and C.CN_DATE = CD.CN_DATE) 
where C.CN_DATE = @data_date  
and CD.SUB_BOP_ID = @sub_bop_id 
and C.CATEGORY_CODE = @category_code  
and CD.SUB_BOP_ID = @sub_bop_id 
and C.CN_ID not in (select C1.CN_ID
                     from PM_CREDIT_NOTE C1
                     inner join PM_BATCH_DCB_CREDIT_NOTE D1 on (C1.CN_ID = D1.CN_ID and C1.CN_DATE = D1.CN_DATE)
                     where C1.CN_DATE = @data_date
                     and C1.CATEGORY_CODE = @category_code) 
order by BANK_CODE, MOBILE_NO, CN_DATE, REFUND_TOTAL_AMT, DCB_ID

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} -Jutf8 -w200

${EXECUTE_PATH}/reconcile -c ${CONFIG_NAME} --order-id ${RECONCILE_ORDER_ID}
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
where B.ORDER_ID = ${RECONCILE_ORDER_ID}
and MT.TABLE_NAME = 'PM_BATCH_DCB'
and RM.RECONCILE_CODE = '002'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE with RECONCILE_CODE=002,TABLE_NAME=PM_BATCH_DCB : ${COUNT}"
if [ "$COUNT" -ne "0" ]; then
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
where B.ORDER_ID = ${RECONCILE_ORDER_ID}
and MT.TABLE_NAME = 'PM_CREDIT_NOTE'
and RM.RECONCILE_CODE = '002'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE with RECONCILE_CODE=002,TABLE_NAME=PM_CREDIT_NOTE : ${COUNT}"
if [ "$COUNT" -ne "0" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
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
--and D.TRANS_DTM = '20160805'
and D.FACE_VALUE = 3.00
and D.VALIDITY = null
and RM.RECONCILE_CODE = '002'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo -e "found PM_PREPAID_BATCH_RECONCILE_DIFF with 
RECONCILE_CODE=002,D_MOBILE_NO=0817037536,FACE_VALUE=3.00,VALIDITY=null : ${COUNT}"
if [ "$COUNT" -ne "0" ]; then
  exit $RET_FAIL
fi

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
and R.DIFF_BOO = 'N'
and R.LAST_BOO = 'Y'

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} -Jutf8 -w200

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
and R.DIFF_BOO = 'N'
and R.LAST_BOO = 'Y'
and R.REF_1_RECORD = 1
and R.REF_1_AMT = 3.00
and R.REF_1_VALIDITY = 0
and R.REF_2_RECORD = 1
and R.REF_2_AMT = 3.00
and R.REF_2_VALIDITY = 0
and R.REF_1_L_REF_2_RECORD = 0
and R.REF_1_L_REF_2_AMT = 0
and R.REF_1_L_REF_2_VALIDITY = 0
and R.REF_1_M_REF_2_RECORD = 0
and R.REF_1_M_REF_2_AMT = 0
and R.REF_1_M_REF_2_VALIDITY = 0

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
COUNT=$(cat ${WORKING_PATH}/count)
echo -e "found PM_PREPAID_BATCH_RECONCILE with RECONCILE_CODE=002,LAST_BOO=Y,DIFF_BOO=N
   ,REF_1_RECORD=1,REF_1_AMT=3.00,REF_1_VALIDITY=0
   ,REF_2_RECORD=1,REF_2_AMT=3.00,REF_2_VALIDITY=0
   ,REF_1_L_REF_2_RECORD=0,REF_1_L_REF_2_AMT=0,REF_1_L_REF_2_VALIDITY=0
   ,REF_1_M_REF_2_RECORD=0,REF_1_M_REF_2_AMT=0,REF_1_M_REF_2_VALIDITY=0 : ${COUNT}"
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
