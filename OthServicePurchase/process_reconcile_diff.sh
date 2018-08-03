ORDER_ID=$(cat ${WORKING_PATH}/order_id)

# Expected OK
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
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_LOAD_BATCH with LOAD_TOTAL=1,LOAD_SUCCESS=1,LOAD_ERROR=0 : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
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

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_LOAD_BATCH_REJECT : ${COUNT}"

if [ "$COUNT" -ne "0" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_INF_BATCH_DCB I" >> ${SCRIPT}
echo -e "where I.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count\n\ngo" >> ${SCRIPT}

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

echo -e "use PMDB\ngo" > ${SCRIPT}
echo -e "\nset nocount on" >> ${SCRIPT}
echo -e "\ndeclare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_BATCH_DCB B" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH L on (B.BATCH_ID = L.BATCH_ID)" >> ${SCRIPT}
echo -e "where L.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and B.RECORD_STATUS = 'SC'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_BATCH_DCB with RECORD_STATUS=SC : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

RECONCILE_ORDER_ID=$(cat ${WORKING_PATH}/reconcile_order_id)

# Skip Generate Document by purpose
#${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PM_BATCH_DCB_GEN_RECEIPT @order_id=${ORDER_ID}
#RET=$?
#if [ $RET -ne 0 ]; then
#  exit $RET_FAIL
#fi

#echo -e "use PMDB\ngo" > ${SCRIPT}
#echo -e "\nset nocount on" >> ${SCRIPT}
#echo -e "\ndeclare @count int" >> ${SCRIPT}
#echo -e "select @count = count(*)" >> ${SCRIPT}
#echo -e "from PM_BATCH_DCB B" >> ${SCRIPT}
#echo -e "inner join PM_PREPAID_LOAD_BATCH L on (B.BATCH_ID = L.BATCH_ID)" >> ${SCRIPT}
#echo -e "where L.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
#echo -e "and B.CN_ID != null" >> ${SCRIPT}
#echo -e "\nprint '%1!', @count\n\ngo" >> ${SCRIPT}

#isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

#COUNT=$(cat ${WORKING_PATH}/count)

#echo "found PM_BATCH_DCB with CN_ID!=null : ${COUNT}"

#if [ "$COUNT" -ne "1" ]; then
#  exit $RET_FAIL
#fi

#echo -e "use PMDB\ngo" > ${SCRIPT}
#echo -e "\nset nocount on" >> ${SCRIPT}
#echo -e "\ndeclare @count int" >> ${SCRIPT}
#echo -e "select @count = count(*)" >> ${SCRIPT}
#echo -e "from PM_PREPAID_LOAD_BATCH" >> ${SCRIPT}
#echo -e "where ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
#echo -e "and BATCH_STATE = 'G' and PROCESS_STATUS = 'SC'" >> ${SCRIPT}
#echo -e "\nprint '%1!', @count\n\ngo" >> ${SCRIPT}

#isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

#COUNT=$(cat ${WORKING_PATH}/count)

#echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=G,PROCESS_STATUS=SC : ${COUNT}"

#if [ "$COUNT" -ne "1" ]; then
#  exit $RET_FAIL
#fi

${EXECUTE_PATH}/reconcile -c ${CONFIG_NAME} --order-id ${RECONCILE_ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

echo -e "
use PMDB

go

set nocount on

declare @batch_rcc_id unsigned bigint

select @batch_rcc_id = BR.BATCH_RCC_ID
from PM_PREPAID_LOAD_BATCH B
inner join PM_PREPAID_BATCH_RECONCILE BR on (B.BATCH_ID = BR.BATCH_ID)
where B.ORDER_ID = ${RECONCILE_ORDER_ID}
and BR.LAST_BOO = 'Y'

print '%1!', @batch_rcc_id

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/batch_rcc_id

BATCH_RCC_ID=$(cat ${WORKING_PATH}/batch_rcc_id)

echo "BATCH_RCC_ID=${BATCH_RCC_ID}"

echo -e "
use PMDB

go

set nocount on

select BRF.BATCH_RCC_ID, BRF.BATCH_ID
from PM_PREPAID_BATCH_RECONCILE BR
inner join PM_PREPAID_LOAD_BATCH B on (BR.BATCH_ID = B.BATCH_ID)
inner join PM_PREPAID_BATCH_RECONCILE_FILE BRF on (BR.BATCH_RCC_ID = BRF.BATCH_RCC_ID)
where BRF.BATCH_RCC_ID = ${BATCH_RCC_ID}

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

echo -e "
use PMDB

go

set nocount on

select J.ORDER_ID, J.FILE_NAME, J.RUN_DATE, BR.BATCH_RCC_ID
        , BR.VERSION_NO
        , DCB.BANK_CODE
        , DCB.BILLING_SYSTEM
        , DCB.BATCH_ID
        , count(*) as REF_1_RECORD
        , sum(DCB.PARTIAL_FEE) as REF_1_AMT
        , count(CN.CN_ID) as REF_2_RECORD
        , sum(isnull(CN.REFUND_TOTAL_AMT,0)) as REF_2_AMT
        , case when count(*) > count(CN.CN_ID) then (count(*) - count(CN.CN_ID)) else 0 end as REF1_M_REF2_RECORD
        , case when SUM(isnull(DCB.PARTIAL_FEE,0)) > SUM(isnull(CN.REFUND_TOTAL_AMT,0)) then (SUM(isnull(DCB.PARTIAL_FEE,0)) - SUM(isnull(CN.REFUND_TOTAL_AMT,0))) else 0 end as REF1_M_REF2_AMT
        , case when count(CN.CN_ID) > count(*) then (count(CN.CN_ID) - count(*)) else 0 end as REF1_L_REF2_RECORD
        , case when SUM(isnull(CN.REFUND_TOTAL_AMT,0)) > SUM(isnull(DCB.PARTIAL_FEE,0)) then (SUM(isnull(CN.REFUND_TOTAL_AMT,0)) - SUM(isnull(DCB.PARTIAL_FEE,0))) else 0 end as REF1_L_REF2_AMT
        , BR.CREATED_BY
        , getdate() as CREATED
        , BR.LAST_UPD_BY
        , getdate() as LAST_UPD
        from PM_PREPAID_BATCH_RECONCILE BR
        inner join PM_PREPAID_LOAD_BATCH B on (BR.BATCH_ID = B.BATCH_ID)
        inner join PM_PREPAID_BATCH_RECONCILE_FILE BRF on (BR.BATCH_RCC_ID = BRF.BATCH_RCC_ID)
        inner join PM_PREPAID_LOAD_BATCH LB on (BRF.BATCH_ID = LB.BATCH_ID)
        inner join PM_BATCH_DCB DCB on (LB.BATCH_ID = DCB.BATCH_ID)
        inner join PM_BATCH_DCB_CREDIT_NOTE DCBC on (DCB.DCB_ID = DCBC.DCB_ID)
        inner join PM_JOB_ORDER J on (LB.ORDER_ID = J.ORDER_ID)
        inner join PM_CONTENT_PARTNER CP on convert(bigint,DCB.CONTENT_ID) = CP.CONTENT_ID
        inner join PM_CONTENT_PARTNER_MAPPING CPM on CP.CONTENT_ID = CPM.CONTENT_ID and DCB.END_CAUSE = CPM.CAUSE_ID
        inner join PM_SUB_BUSINESS_OF_PAYMENT SBOP on CPM.SUB_BOP_ID = SBOP.SUB_BOP_ID
        left join PM_CREDIT_NOTE CN on (DCBC.CN_ID = CN.CN_ID and DCBC.CN_DATE = CN.CN_DATE)
        where SBOP.SUB_BOP_CODE = 'PU'
        and B.ORDER_ID = ${RECONCILE_ORDER_ID}
        and BR.RECONCILE_STATUS = 'S'
        group by J.ORDER_ID, J.FILE_NAME, J.RUN_DATE, BR.BATCH_RCC_ID
        , BR.VERSION_NO
        , DCB.BANK_CODE
        , DCB.BILLING_SYSTEM
        , DCB.BATCH_ID
        , BR.CREATED_BY
        , BR.LAST_UPD_BY
        order by BR.BATCH_RCC_ID, BR.VERSION_NO

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE T" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_BATCH_RECONCILE_DIFF D on (T.DIFF_ID = D.DIFF_ID)" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_BATCH_RECONCILE R on (D.BATCH_RCC_ID = R.BATCH_RCC_ID)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "inner join PM_JOB_ORDER O on (B.ORDER_ID = O.ORDER_ID)" >> ${SCRIPT}
echo -e "inner join PM_FILE_CONFIG F on (O.TEMPLATE_CODE = F.TEMPLATE_CODE)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING M on (F.FILE_TYPE = M.FILE_TYPE)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING_TABLE MT on (M.RECONCILE_ID = MT.RECONCILE_ID and T.TABLE_ID = MT.TABLE_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${RECONCILE_ORDER_ID}" >> ${SCRIPT}
echo -e "and MT.TABLE_NAME = 'PM_BATCH_DCB'" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '002'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE with RECONCILE_CODE=002,TABLE_NAME=PM_BATCH_DCB : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_PREPAID_BATCH_RECONCILE_DIFF D" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_BATCH_RECONCILE R on (D.BATCH_RCC_ID = R.BATCH_RCC_ID)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${RECONCILE_ORDER_ID}" >> ${SCRIPT}
echo -e "and D.D_MOBILE_NO = '0817037536'" >> ${SCRIPT}
echo -e "and D.TRANS_DTM = '20160805'" >> ${SCRIPT}
echo -e "and D.FACE_VALUE = 100" >> ${SCRIPT}
echo -e "and D.VALIDITY = null" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '002'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_BATCH_RECONCILE_DIFF with RECONCILE_CODE=002,D_MOBILE_NO=0817037536,TRANS_DTM=20160805,FACE_VALUE=100,VALIDITY=null : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_PREPAID_BATCH_RECONCILE R" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${RECONCILE_ORDER_ID}" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '002'" >> ${SCRIPT}
echo -e "and R.DIFF_BOO = 'Y'" >> ${SCRIPT}
echo -e "and R.LAST_BOO = 'Y'" >> ${SCRIPT}
echo -e "and R.REF_1_RECORD = 1" >> ${SCRIPT}
echo -e "and R.REF_1_AMT = 100" >> ${SCRIPT}
echo -e "and R.REF_1_VALIDITY = 0" >> ${SCRIPT}
echo -e "and R.REF_2_RECORD = 0" >> ${SCRIPT}
echo -e "and R.REF_2_AMT = 0" >> ${SCRIPT}
echo -e "and R.REF_2_VALIDITY = 0" >> ${SCRIPT}
echo -e "and R.REF_1_L_REF_2_RECORD = 1" >> ${SCRIPT}
echo -e "and R.REF_1_L_REF_2_AMT = 100" >> ${SCRIPT}
echo -e "and R.REF_1_L_REF_2_VALIDITY = 0" >> ${SCRIPT}
echo -e "and R.REF_1_M_REF_2_RECORD = 0" >> ${SCRIPT}
echo -e "and R.REF_1_M_REF_2_AMT = 0" >> ${SCRIPT}
echo -e "and R.REF_1_M_REF_2_VALIDITY = 0" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_BATCH_RECONCILE with RECONCILE_CODE=002,LAST_BOO=Y,DIFF_BOO=Y"
echo "      ,REF_1_RECORD=1,REF_1_AMT=100,REF_1_VALIDITY=0"
echo "      ,REF_2_RECORD=0,REF_2_AMT=0,REF_2_VALIDITY=0"
echo "      ,REF_1_L_REF_2_RECORD=1,REF_1_L_REF_2_AMT=100,REF_1_L_REF_2_VALIDITY=0"
echo "      ,REF_1_M_REF_2_RECORD=0,REF_1_M_REF_2_AMT=0,REF_1_M_REF_2_VALIDITY=0 : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "
use PMDB

go

declare @batch_rcc_id unsigned bigint

select @batch_rcc_id = R.BATCH_RCC_ID
from PM_PREPAID_BATCH_RECONCILE R
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
where B.ORDER_ID = ${RECONCILE_ORDER_ID}

print '@batch_rcc_id=[%1!]', @batch_rcc_id

select BR.BATCH_RCC_ID
        , BR.VERSION_NO
        , DCB.BANK_CODE
        , DCB.BILLING_SYSTEM
        , DCB.BATCH_ID
        , count(*) as REF_1_RECORD
        , sum(DCB.PARTIAL_FEE) as REF_1_AMT
        , count(CN.CN_ID) as REF_2_RECORD
        , sum(isnull(CN.REFUND_TOTAL_AMT,0)) as REF_2_AMT
        , case when count(*) > count(CN.CN_ID) then (count(*) - count(CN.CN_ID)) else 0 end as REF1_M_REF2_RECORD
        , case when SUM(isnull(DCB.PARTIAL_FEE,0)) > SUM(isnull(CN.REFUND_TOTAL_AMT,0)) then (SUM(isnull(DCB.PARTIAL_FEE,0)) - SUM(isnull(CN.REFUND_TOTAL_AMT,0))) else 0 end as REF1_M_REF2_AMT
        , case when count(CN.CN_ID) > count(*) then (count(CN.CN_ID) - count(*)) else 0 end as REF1_L_REF2_RECORD
        , case when SUM(isnull(CN.REFUND_TOTAL_AMT,0)) > SUM(isnull(DCB.PARTIAL_FEE,0)) then (SUM(isnull(CN.REFUND_TOTAL_AMT,0)) - SUM(isnull(DCB.PARTIAL_FEE,0))) else 0 end as REF1_L_REF2_AMT
        , BR.CREATED_BY
        , getdate() as CREATED
        , BR.LAST_UPD_BY
        , getdate() as LAST_UPD
        from PM_PREPAID_BATCH_RECONCILE BR 
        inner join PM_PREPAID_BATCH_RECONCILE_FILE BRF on (BR.BATCH_RCC_ID = BRF.BATCH_RCC_ID)
        inner join PM_PREPAID_LOAD_BATCH LB on (BRF.BATCH_ID = LB.BATCH_ID)
        inner join PM_BATCH_DCB DCB on (LB.BATCH_ID = DCB.BATCH_ID)
        inner join PM_CONTENT_PARTNER CP on convert(bigint,DCB.CONTENT_ID) = CP.CONTENT_ID
        inner join PM_CONTENT_PARTNER_MAPPING CPM on CP.CONTENT_ID = CPM.CONTENT_ID and DCB.END_CAUSE = CPM.CAUSE_ID
        inner join PM_SUB_BUSINESS_OF_PAYMENT SBOP on CPM.SUB_BOP_ID = SBOP.SUB_BOP_ID
        left join PM_BATCH_DCB_CREDIT_NOTE DCBC on (DCB.DCB_ID = DCBC.DCB_ID)
        left join PM_CREDIT_NOTE CN on (DCBC.CN_ID = CN.CN_ID and DCBC.CN_DATE = CN.CN_DATE)
        where SBOP.SUB_BOP_CODE = 'PU'
        and BR.BATCH_RCC_ID = @batch_rcc_id
        --and BR.RECONCILE_STATUS = 'S'
        group by BR.BATCH_RCC_ID
        , BR.VERSION_NO
        , DCB.BANK_CODE
        , DCB.BILLING_SYSTEM
        , DCB.BATCH_ID
        , BR.CREATED_BY
        , BR.LAST_UPD_BY
        order by BR.BATCH_RCC_ID, BR.VERSION_NO

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} -Jutf8 -w200

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
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_PREPAID_LOAD_BATCH" >> ${SCRIPT}
echo -e "where ORDER_ID = ${RECONCILE_ORDER_ID}" >> ${SCRIPT}
echo -e "and BATCH_STATE = 'R'" >> ${SCRIPT}
echo -e "and PROCESS_STATUS = 'SC'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=R,PROCESS_STATUS=SC : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

cp ${WORKING_PATH}/reconcile_order_id ${WORKING_PATH}/order_id

exit $RET_OK
