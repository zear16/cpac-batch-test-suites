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
echo -e "from PM_INF_PACKAGE_BOS I" >> ${SCRIPT}
echo -e "where I.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count\n\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_INF_PACKAGE_BOS : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

# Expected OK
${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_LOAD_PM_PACKAGE_BOS_FROM_INF @order_id=${ORDER_ID}
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
echo -e "from PM_PACKAGE_BOS A"  >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (A.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PACKAGE_BOS : ${COUNT}"

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
echo -e "where ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and BATCH_STATE = 'C'" >> ${SCRIPT}
echo -e "and PROCESS_STATUS = 'SC'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=C,PROCESS_STATUS=SC : ${COUNT}"

if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "select PB.PRODUCT_ID, P.PACKAGE_TYPE, P.BANK_CODE, PB.MOBILE_NO" >> ${SCRIPT}
echo -e ", convert(char(8), convert(date, PB.OPERATION_DTM), 112) as TRANS_DTM, P.PACKAGE_FEE as TOTAL_AMT" >> ${SCRIPT}
echo -e ", convert(date, PB.OPERATION_DATE, 112) as OPERATION_DATE" >> ${SCRIPT}
echo -e ", P.PACKAGE_CODE, P.PACKAGE_NAME, PB.PACKAGE_BOS_ID" >> ${SCRIPT}
echo -e "from PM_PACKAGE_BOS PB" >> ${SCRIPT}
echo -e "left join PM_PACKAGE P on (PB.PRODUCT_ID = P.PACKAGE_CODE)" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH LB on (PB.BATCH_ID = LB.BATCH_ID)" >> ${SCRIPT}
echo -e "where LB.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

#isql -U${USER} -P${PASS} -S${SERVER} -Jutf8 -i ${SCRIPT}

RECONCILE_ORDER_ID=$(cat ${WORKING_PATH}/reconcile_order_id)

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
from PM_PREPAID_BATCH_RECONCILE BR
inner join PM_PREPAID_LOAD_BATCH B on (BR.BATCH_ID = B.BATCH_ID)
where B.ORDER_ID = ${RECONCILE_ORDER_ID}

print '%1!', @batch_rcc_id

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/batch_rcc_id

BATCH_RCC_ID=$(cat ${WORKING_PATH}/batch_rcc_id)

echo -e "
use PMDB

go

select 
        BR.BATCH_RCC_ID
        , BR.VERSION_NO
        , P.PACKAGE_TYPE
        , count(*) as REF_1_RECORD
        , sum(P.PACKAGE_FEE) as REF_1_AMT
        , count(R.RECEIPT_NO) as REF_2_RECORD
        , isnull(sum(R.TOTAL_AMT),0) as REF_2_AMT
        , case when count(*) > count(R.RECEIPT_NO) then (count(*) - count(R.RECEIPT_NO)) else 0 end as REF1_M_REF2_RECORD
        , case when SUM(isnull(P.PACKAGE_FEE,0)) > SUM(isnull(R.TOTAL_AMT,0)) then (SUM(isnull(P.PACKAGE_FEE,0)) - SUM(isnull(R.TOTAL_AMT,0))) else 0 end as REF1_M_REF2_AMT
        , case when count(R.RECEIPT_NO) > count(*) then (count(R.RECEIPT_NO) - count(*)) else 0 end as REF1_L_REF2_RECORD
        , case when SUM(isnull(R.TOTAL_AMT,0)) > SUM(isnull(P.PACKAGE_FEE,0)) then (SUM(isnull(R.TOTAL_AMT,0)) - SUM(isnull(P.PACKAGE_FEE,0))) else 0 end as REF1_L_REF2_AMT
        , BR.CREATED_BY
        , getdate() as CREATED
        , BR.LAST_UPD_BY
        , getdate() as LAST_UPD
        , PB.BILLING_SYSTEM
        , PB.BATCH_ID
        from PM_PREPAID_BATCH_RECONCILE BR 
        --inner join PM_PREPAID_LOAD_BATCH B on (BR.BATCH_ID = B.BATCH_ID)
        inner join PM_PREPAID_BATCH_RECONCILE_FILE BRF on (BR.BATCH_RCC_ID = BRF.BATCH_RCC_ID)
        inner join PM_PREPAID_LOAD_BATCH LB on (BRF.BATCH_ID = LB.BATCH_ID)
        inner join PM_PACKAGE_BOS PB on (LB.BATCH_ID = PB.BATCH_ID)
        inner join PM_PACKAGE P on (PB.PRODUCT_ID = P.PACKAGE_CODE)
        left join PM_RECEIPT R on (PB.RECEIPT_ID = R.RECEIPT_ID and PB.RECEIPT_DATE = R.RECEIPT_DATE)
        where BR.BATCH_RCC_ID = ${BATCH_RCC_ID}
        and BR.RECONCILE_STATUS = 'S'
        group by P.PACKAGE_TYPE, BR.CREATED_BY,BR.LAST_UPD_BY, PB.BILLING_SYSTEM
        , BR.BATCH_RCC_ID, BR.VERSION_NO, PB.BATCH_ID
        order by P.PACKAGE_TYPE

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
echo -e "and MT.TABLE_NAME = 'PM_PACKAGE_BOS'" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '025'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE with RECONCILE_CODE=025,TABLE_NAME=PM_PACKAGE_BOS : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "select D.D_MOBILE_NO, D.TRANS_DTM, D.PACKAGE_FEE, D.PACKAGE_CODE, D.PACKAGE_NAME" >> ${SCRIPT}
echo -e "from PM_PREPAID_BATCH_RECONCILE_DIFF D" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_BATCH_RECONCILE R on (D.BATCH_RCC_ID = R.BATCH_RCC_ID)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${RECONCILE_ORDER_ID}" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '025'" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

#isql -U${USER} -P${PASS} -S${SERVER} -Jutf8 -i ${SCRIPT}

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
echo -e "and D.D_MOBILE_NO = '0817053436'" >> ${SCRIPT}
echo -e "and D.TRANS_DTM = '20160615'" >> ${SCRIPT}
echo -e "and D.PACKAGE_FEE = 18" >> ${SCRIPT}
echo -e "and D.PACKAGE_CODE = 171601" >> ${SCRIPT}
echo -e "and D.PACKAGE_NAME = 'Test mPAY Voice Package'" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '025'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_BATCH_RECONCILE_DIFF with RECONCILE_CODE=025,D_MOBILE_NO=0817053436,TRANS_DTM=20160615"
echo "      ,PACKAGE_FEE=18,PACKAGE_CODE=171601,PACKAGE_NAME=Test mPAY Voice Package : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "select R.REF_1_RECORD, R.REF_1_AMT, R.REF_1_VALIDITY" >> ${SCRIPT}
echo -e ", R.REF_2_RECORD, R.REF_2_AMT, R.REF_2_VALIDITY" >> ${SCRIPT}
echo -e ", R.REF_1_M_REF_2_RECORD, R.REF_1_M_REF_2_AMT, R.REF_1_M_REF_2_VALIDITY" >> ${SCRIPT}
echo -e ", R.REF_1_L_REF_2_RECORD, R.REF_1_L_REF_2_AMT,  R.REF_1_L_REF_2_VALIDITY" >> ${SCRIPT}
echo -e "from PM_PREPAID_BATCH_RECONCILE R" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${RECONCILE_ORDER_ID}" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '025'" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

#isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

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
echo -e "and RM.RECONCILE_CODE = '025'" >> ${SCRIPT}
echo -e "and R.DIFF_BOO = 'Y'" >> ${SCRIPT}
echo -e "and R.LAST_BOO = 'Y'" >> ${SCRIPT}
echo -e "and R.REF_1_RECORD = 1" >> ${SCRIPT}
echo -e "and R.REF_1_AMT = 18" >> ${SCRIPT}
echo -e "and R.REF_1_VALIDITY = 0" >> ${SCRIPT}
echo -e "and R.REF_2_RECORD = 0" >> ${SCRIPT}
echo -e "and R.REF_2_AMT = 0" >> ${SCRIPT}
echo -e "and R.REF_2_VALIDITY = 0" >> ${SCRIPT}
echo -e "and R.REF_1_L_REF_2_RECORD = 1" >> ${SCRIPT}
echo -e "and R.REF_1_L_REF_2_AMT = 18" >> ${SCRIPT}
echo -e "and R.REF_1_L_REF_2_VALIDITY = 0" >> ${SCRIPT}
echo -e "and R.REF_1_M_REF_2_RECORD = 0" >> ${SCRIPT}
echo -e "and R.REF_1_M_REF_2_AMT = 0" >> ${SCRIPT}
echo -e "and R.REF_1_M_REF_2_VALIDITY = 0" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_BATCH_RECONCILE with RECONCILE_CODE=007,LAST_BOO=Y,DIFF_BOO=Y"
echo "      ,REF_1_RECORD=1,REF_1_AMT=18,REF_1_VALIDITY=0"
echo "      ,REF_2_RECORD=0,REF_2_AMT=0,REF_2_VALIDITY=0"
echo "      ,REF_1_L_REF_2_RECORD=1,REF_1_L_REF_2_AMT=18,REF_1_L_REF_2_VALIDITY=0"
echo "      ,REF_1_M_REF_2_RECORD=0,REF_1_M_REF_2_AMT=0,REF_1_M_REF_2_VALIDITY=0 : ${COUNT}"
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

