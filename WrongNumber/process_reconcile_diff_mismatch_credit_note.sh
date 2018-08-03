ORDER_ID=$(cat ${WORKING_PATH}/order_id)

SCRIPT=${WORKING_PATH}/check.sql
echo -e "
use PMDB

go

set nocount on

select AD2.MOBILE_NO as S_MOBILE_NO, R.MOBILE_NO as D_MOBILE_NO, AD.MOBILE_NO, AD2.REF_MOBILE_NO
, R.TOTAL_AMT, R.RECEIPT_ID
, R.RECEIPT_NO, convert(char(8), R.RECEIPT_DATE, 112) as RECEIPT_DATE, R.RECEIPT_STATUS
from PM_RECEIPT R
inner join PM_RECEIPT_DTL RD on (R.RECEIPT_ID = RD.RECEIPT_ID and R.RECEIPT_DATE = RD.RECEIPT_DATE)
left join PM_ADJUST_TRANSACTION AD on (R.RECEIPT_DATE = AD.ADJUST_DATE
and R.RECEIPT_ID = AD.RECEIPT_ID and R.RECEIPT_DATE = AD.RECEIPT_DATE)
left join PM_ADJUST_TRANSACTION AD2 on (R.RECEIPT_DATE = AD2.ADJUST_DATE
and AD.MOBILE_NO = AD2.REF_MOBILE_NO and AD.TRANS_NO = AD2.TRANS_NO)
where R.RECEIPT_DATE = '20160615'
and R.BANK_CODE = 804

select 1, AD2.MOBILE_NO as S_MOBILE_NO, R.MOBILE_NO as D_MOBILE_NO, R.TOTAL_AMT, R.RECEIPT_ID
, R.RECEIPT_NO, convert(char(8), R.RECEIPT_DATE, 112) as RECEIPT_DATE, R.RECEIPT_STATUS 
from PM_RECEIPT R 
inner join PM_RECEIPT_DTL RD on (R.RECEIPT_ID = RD.RECEIPT_ID and R.RECEIPT_DATE = RD.RECEIPT_DATE) 
left join PM_ADJUST_TRANSACTION AD on (R.RECEIPT_DATE = AD.ADJUST_DATE 
and R.RECEIPT_ID = AD.RECEIPT_ID and R.RECEIPT_DATE = AD.RECEIPT_DATE) 
left join PM_ADJUST_TRANSACTION AD2 on (R.RECEIPT_DATE = AD2.ADJUST_DATE 
and AD.MOBILE_NO = AD2.REF_MOBILE_NO and AD.TRANS_NO = AD2.TRANS_NO) 
where R.RECEIPT_DATE = '20160615' 
and R.BANK_CODE = 804 
union all 
select 2, AD.MOBILE_NO as S_MOBILE_NO, AD2.MOBILE_NO as D_MOBILE_NO, AD2.ADJUST_AMT as TOTAL_AMT, null as RECEIPT_ID
, AD2.RECEIPT_NO, convert(char(8), AD2.RECEIPT_DATE, 112) as RECEIPT_DATE, null as RECEIPT_STATUS 
from PM_ADJUST_TRANSACTION AD 
inner join PM_ADJUST_TRANSACTION AD2 on (AD.TRANS_NO = AD2.TRANS_NO and AD.MOBILE_NO = AD2.REF_MOBILE_NO) 
inner join PM_SUB_CAUSE SC on (AD.SUB_CAUSE_ID = SC.SUB_CAUSE_ID) 
where AD.ADJUST_DATE = '20160615' 
and SC.SUB_CAUSE_CODE = (
select FIELD1_VALUE 
from PM_SYSTEM_ATTRIBUTE_DTL 
where ATTRIBUTE_CODE = 'CPAC_PARAM' 
and DB_VALUE = 'WRONG_NUMBER_SUB_CAUSE') 
and AD2.RECEIPT_NO is not null 
and AD2.BILLING_SYSTEM = 'RTBS' 
order by MOBILE_NO, TOTAL_AMT

go
" > ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

${EXECUTE_PATH}/reconcile -c ${CONFIG_NAME} --order-id=${ORDER_ID}
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
echo -e "from PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE T" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_BATCH_RECONCILE_DIFF D on (T.DIFF_ID = D.DIFF_ID)" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_BATCH_RECONCILE R on (D.BATCH_RCC_ID = R.BATCH_RCC_ID)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "inner join PM_JOB_ORDER O on (B.ORDER_ID = O.ORDER_ID)" >> ${SCRIPT}
echo -e "inner join PM_FILE_CONFIG F on (O.TEMPLATE_CODE = F.TEMPLATE_CODE)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING M on (F.FILE_TYPE = M.FILE_TYPE)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING_TABLE MT on (M.RECONCILE_ID = MT.RECONCILE_ID and T.TABLE_ID = MT.TABLE_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and MT.TABLE_NAME = 'PM_CREDIT_NOTE'" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '026'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE with RECONCILE_CODE=026,TABLE_NAME=PM_CREDIT_NOTE : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "select D.D_MOBILE_NO, D.TRANS_DTM, D.FACE_VALUE, D.VALIDITY" >> ${SCRIPT}
echo -e "from PM_PREPAID_BATCH_RECONCILE_DIFF D" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_BATCH_RECONCILE R on (D.BATCH_RCC_ID = R.BATCH_RCC_ID)" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '026'" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

#isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

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
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and D.S_MOBILE_NO = '0817053436'" >> ${SCRIPT}
echo -e "and D.TRANS_DTM = '20160615'" >> ${SCRIPT}
echo -e "and D.FACE_VALUE = 18" >> ${SCRIPT}
echo -e "and D.VALIDITY = null" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '026'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_BATCH_RECONCILE_DIFF with RECONCILE_CODE=026,S_MOBILE_NO=0817053436,TRANS_DTM=20160615,FACE_VALUE=18,VALIDITY=null : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "select DIFF_BOO, LAST_BOO, REF_1_RECORD, REF_1_AMT, REF_1_VALIDITY" >> ${SCRIPT}
echo -e ", REF_2_RECORD, REF_2_AMT, REF_2_VALIDITY" >> ${SCRIPT}
echo -e ", REF_3_RECORD, REF_3_AMT, REF_3_VALIDITY" >> ${SCRIPT}
echo -e "from PM_PREPAID_BATCH_RECONCILE R" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '026'" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

#isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_PREPAID_BATCH_RECONCILE R" >> ${SCRIPT}
echo -e "inner join PM_RECONCILE_MAPPING RM on (R.RECONCILE_ID = RM.RECONCILE_ID)" >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and RM.RECONCILE_CODE = '026'" >> ${SCRIPT}
echo -e "and R.DIFF_BOO = 'Y'" >> ${SCRIPT}
echo -e "and R.LAST_BOO = 'Y'" >> ${SCRIPT}
echo -e "and R.REF_1_RECORD = 1" >> ${SCRIPT}
echo -e "and R.REF_1_AMT = 16" >> ${SCRIPT}
echo -e "and R.REF_1_VALIDITY = 0" >> ${SCRIPT}
echo -e "and R.REF_2_RECORD = 1" >> ${SCRIPT}
echo -e "and R.REF_2_AMT = 16" >> ${SCRIPT}
echo -e "and R.REF_2_VALIDITY = 0" >> ${SCRIPT}
echo -e "and R.REF_3_RECORD = 2" >> ${SCRIPT}
echo -e "and R.REF_3_AMT = 34" >> ${SCRIPT}
echo -e "and R.REF_3_VALIDITY = 0" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count

COUNT=$(cat ${WORKING_PATH}/count)

echo "found PM_PREPAID_BATCH_RECONCILE with RECONCILE_CODE=026,LAST_BOO=Y,DIFF_BOO=Y"
echo "      ,REF_1_RECORD=1,REF_1_AMT=16,REF_1_VALIDITY=0"
echo "      ,REF_2_RECORD=1,REF_2_AMT=16,REF_2_VALIDITY=0"
echo "      ,REF_3_RECORD=2,REF_3_AMT=34,REF_3_VALIDITY=0 : ${COUNT}"
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

exit $RET_OK

