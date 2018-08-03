ORDER_ID=$(cat ${WORKING_PATH}/order_id)

# Expected OK
${EXECUTE_PATH}/recharge -c ${CONFIG_NAME} --order-id ${ORDER_ID}
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

${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PM_RECHARGE_GEN_RECEIPT @order_id=${ORDER_ID}
RET=$?
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
and R.RECEIPT_NO != null

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_RECHARGE with RECEIPT_NO!=null : ${COUNT}"
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

ORDER_ID=$(cat ${WORKING_PATH}/reconcile_order_id)

# Replace old order_id file
cp ${WORKING_PATH}/reconcile_order_id ${WORKING_PATH}/order_id

echo -e "use PMDB

go

select R.RECHARGE_ID, R.RECHARGE_CHANNEL as SERVICE_ID, R.RECHARGE_PARTNER_ID as BANK_CODE, R.MOBILE_NO
, convert(char(8), R.RECHARGE_DATE, 112) as TRANSACTION_DATE, R.RECHARGE_AMT as TOTAL_AMT
, R.CARD_BATCH_ID ||  R.CARD_SERIAL_NO  as BATCH_NO, R.RECEIPT_NO, R.RECEIPT_DATE, R.RECEIPT_STATUS
 from PM_RECHARGE R
 where R.RECHARGE_DATE = '20160616'
 and R.SPECIFICATION_ID <> 1009001
 and R.IS_TEST_NUMBER_BOO = 'N'
 and R.RECORD_STATUS != NULL
 order by SERVICE_ID, BANK_CODE, MOBILE_NO, BATCH_NO, TOTAL_AMT

go
" > ${SCRIPT}
#isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

echo -e "use PMDB

go

select '1' as SOURCE, R.RECHARGE_CHANNEL as SERVICE_ID, R.RECHARGE_PARTNER_ID as BANK_CODE, R.MOBILE_NO
, convert(char(8), R.RECHARGE_DATE, 112) as TRANSACTION_DATE, R.RECEIPT_AMT as TOTAL_AMT
, R.CARD_BATCH_ID ||  R.CARD_SERIAL_NO  as BATCH_NO, R.RECEIPT_NO, R.RECEIPT_DATE, R.RECEIPT_STATUS
 from PM_RECHARGE R
 where R.RECHARGE_DATE = '20160616'
 and R.SPECIFICATION_ID <> 1009001
 and R.IS_TEST_NUMBER_BOO = 'N'
 and R.CONVERT_TO_RECEIPT_BOO = 'N'
 and R.RECEIPT_NO is not null
 union all
 select '2' as SOURCE, RP.SERVICE_ID, R.BANK_CODE, RD.MOBILE_NO
, R.RECEIPT_DATE as TRANSACTION_DATE, RD.TOTAL_AMT
, RDP.PREPAID_BATCH_NO || RDP.PREPAID_SERIAL_NO as BATCH_NO, R.RECEIPT_NO, R.RECEIPT_DATE, R.RECEIPT_STATUS
 from PM_RECEIPT_DTL RD
 inner join PM_RECEIPT_DTL_PREPAID RDP on (RD.RECEIPT_DTL_ID = RDP.RECEIPT_DTL_ID and RD.RECEIPT_DATE = RDP.RECEIPT_DATE)
 inner join PM_RECEIPT R on (RD.RECEIPT_ID = R.RECEIPT_ID and RD.RECEIPT_DATE = R.RECEIPT_DATE)
 inner join PM_RECEIPT_PREPAID RP on (R.RECEIPT_ID = RP.RECEIPT_ID and R.RECEIPT_DATE = RP.RECEIPT_DATE)
 inner join PM_SUB_BUSINESS_OF_PAYMENT BOP on (RD .SUB_BOP_ID = BOP.SUB_BOP_ID)
 where RD.RECEIPT_DATE = '20160616'
 and BOP.SUB_BOP_CODE = 'PT'
 order by SERVICE_ID, BANK_CODE, MOBILE_NO, BATCH_NO, TOTAL_AMT
go
" > ${SCRIPT}
#isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

${EXECUTE_PATH}/reconcile -c ${CONFIG_NAME} --order-id=${ORDER_ID}
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
where B.ORDER_ID = ${ORDER_ID}
and MT.TABLE_NAME = 'PM_RECEIPT'
and RM.RECONCILE_CODE = '001'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE with RECONCILE_CODE=001,TABLE_NAME=PM_RECEIPT : ${COUNT}"
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
and D.D_MOBILE_NO = '0817053436'
and D.TRANS_DTM = '20160616'
and D.FACE_VALUE = 6746
and D.VALIDITY = null
and RM.RECONCILE_CODE = '001'

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_BATCH_RECONCILE_DIFF with RECONCILE_CODE=001
     ,D_MOBILE_NO=0817053436,TRANS_DTM=20160616,FACE_VALUE=6746,VALIDITY=null : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

set nocount on

select DIFF_BOO, LAST_BOO, REF_1_RECORD, REF_1_AMT, REF_1_VALIDITY
, REF_2_RECORD, REF_2_AMT, REF_2_VALIDITY, REF_1_L_REF_2_RECORD
, REF_1_L_REF_2_AMT, REF_1_L_REF_2_VALIDITY, REF_1_M_REF_2_RECORD
, REF_1_M_REF_2_AMT, REF_1_M_REF_2_VALIDITY
from PM_PREPAID_BATCH_RECONCILE R
inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
where B.ORDER_ID = ${ORDER_ID}
and RM.RECONCILE_CODE = '001'

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} -Jutf8 -w200

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_PREPAID_BATCH_RECONCILE R
inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
where B.ORDER_ID = ${ORDER_ID}
and RM.RECONCILE_CODE = '001'
and R.DIFF_BOO = 'Y'
and R.LAST_BOO = 'Y'
and R.REF_1_RECORD = 1
and R.REF_1_AMT = 6746
and R.REF_1_VALIDITY = 0
and R.REF_2_RECORD = 2
and R.REF_2_AMT = 13492
and R.REF_2_VALIDITY = 0
and R.REF_1_L_REF_2_RECORD = 0
and R.REF_1_L_REF_2_AMT = 0
and R.REF_1_L_REF_2_VALIDITY = 0
and R.REF_1_M_REF_2_RECORD = 1
and R.REF_1_M_REF_2_AMT = 6746
and R.REF_1_M_REF_2_VALIDITY = 0

print '%1!', @count

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_BATCH_RECONCILE with RECONCILE_CODE=001,LAST_BOO=Y,DIFF_BOO=Y
      ,REF_1_RECORD=1,REF_1_AMT=6746,REF_1_VALIDITY=0
      ,REF_2_RECORD=2,REF_2_AMT=13492,REF_2_VALIDITY=0
      ,REF_1_L_REF_2_RECORD=0,REF_1_L_REF_2_AMT=0,REF_1_L_REF_2_VALIDITY=0
      ,REF_1_M_REF_2_RECORD=1,REF_1_M_REF_2_AMT=6746,REF_1_M_REF_2_VALIDITY=0 : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

echo -e "use PMDB

go

declare @batch_rcc_id unsigned bigint

select @batch_rcc_id = R.BATCH_RCC_ID
from PM_PREPAID_BATCH_RECONCILE R
inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
where B.ORDER_ID = ${ORDER_ID}

SELECT
          BR.BATCH_RCC_ID
          , BR.VERSION_NO
          , C.RECHARGE_DATE
          --, CRS.CATEGORY_CODE
          --, RS.BANK_CODE
          --, RS.SERVICE_ID
          , count(*) as REF1_RECORD
          , SUM(isnull(C.RECHARGE_AMT,0)) as REF1_AMT
          , count(C.RECEIPT_NO) as REF2_RECORD
          , SUM(isnull(C.RECEIPT_AMT,0)) as REF2_AMT
          , case 
          when count(*) > count(C.RECEIPT_NO) then (count(*) - count(C.RECEIPT_NO)) 
          else 0 end as REF1_M_REF2_RECORD
          , case 
          when SUM(isnull(C.RECHARGE_AMT,0)) > SUM(isnull(C.RECEIPT_AMT,0)) 
            then (SUM(isnull(C.RECHARGE_AMT,0)) - SUM(isnull(C.RECEIPT_AMT,0))) 
          else 0 end as REF1_M_REF2_AMT
          , case 
          when count(C.RECEIPT_NO) > count(*) then (count(C.RECEIPT_NO) - count(*)) 
          else 0 end as REF1_L_REF2_RECORD
          , case 
          when SUM(isnull(C.RECEIPT_AMT,0)) > SUM(isnull(C.RECHARGE_AMT,0)) 
            then (SUM(isnull(C.RECEIPT_AMT,0)) - SUM(isnull(C.RECHARGE_AMT,0))) 
          else 0 end as REF1_L_REF2_AMT
          , BR.CREATED_BY
          , getdate() as CREATED
          , BR.LAST_UPD_BY
          , getdate() as LAST_UPD
          , C.COMPANY_ID
          , C.BILLING_SYSTEM
          , C.BATCH_ID
          , C.RECHARGE_PARTNER_ID
          --, RS.BANK_CODE
        from PM_PREPAID_BATCH_RECONCILE BR
        inner join PM_PREPAID_BATCH_RECONCILE_FILE BRF on (BR.BATCH_RCC_ID = BRF.BATCH_RCC_ID)
        inner join PM_PREPAID_LOAD_BATCH LB on (BRF.BATCH_ID = LB.BATCH_ID)
        inner join PM_RECHARGE C on (LB.BATCH_ID = C.BATCH_ID)
        --left join PM_RECHARGE_SERVICE RS on (C.RECHARGE_CHANNEL = RS.SERVICE_ID 
        --and isnull(C.RECHARGE_PARTNER_ID,0) = isnull(RS.BANK_CODE,0))
        --left join PM_CFG_RECHARGE_SERVICE CRS on (RS.SERVICE_ROW_ID = CRS.SERVICE_ROW_ID)
        --left join PM_PAYMENT_CATEGORY CAT on (CRS.CATEGORY_CODE = CAT.CATEGORY_CODE)
        where BR.BATCH_RCC_ID = @batch_rcc_id
        and BR.RECONCILE_STATUS = 'S'
        group by 
        -- CRS.CATEGORY_CODE, 
        --RS.BANK_CODE, RS.SERVICE_ID, 
        BR.CREATED_BY, BR.LAST_UPD_BY
        , C.RECHARGE_DATE,BR.BATCH_RCC_ID, BR.VERSION_NO
        , C.COMPANY_ID, C.BILLING_SYSTEM, C.BATCH_ID
        -- order by RS.BANK_CODE, RS.SERVICE_ID

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} -Jutf8 -w200

echo -e "use PMDB

go

set nocount on

declare @count int

select @count = count(*)
from PM_PREPAID_LOAD_BATCH B
inner join PM_PREPAID_BATCH_RECONCILE BR on (B.BATCH_ID = BR.BATCH_ID)
inner join PM_PREPAID_BATCH_RECONCILE_DTL RD on (BR.BATCH_RCC_ID = RD.BATCH_RCC_ID)
where B.ORDER_ID = ${ORDER_ID}
and BR.LAST_BOO = 'Y'

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
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_PREPAID_LOAD_BATCH with BATCH_STATE=R,PROCESS_STATUS=SC : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

exit $RET_OK

