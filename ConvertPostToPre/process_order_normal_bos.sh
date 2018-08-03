ORDER_ID=$(cat ${WORKING_PATH}/order_id)

SCRIPT=${WORKING_PATH}/check.sql
echo -e "
use PMDB

go

set nocount on

create table #PM_MAP_NETWORK_TYPE (
  NETWORK_TYPE varchar(50)     not null unique,
  COMPANY_ID   unsigned bigint not null
)

insert into #PM_MAP_NETWORK_TYPE
(NETWORK_TYPE, COMPANY_ID)
select DB_VALUE, convert(unsigned bigint,FIELD1_VALUE)
from PM_SYSTEM_ATTRIBUTE_DTL
where ATTRIBUTE_CODE = 'NETWORK_TYPE_COMPANY'

select PBA.ACCNT_NO, PI.MOBILE_NO, BA.BILLING_SYSTEM, 'WT', 0
, BA.ACCNT_NO, N.COMPANY_ID
from CPDB..SFF_ORDER O
inner join CPDB..SFF_ORDER_SERVICE_INSTANCE OI on (O.ROW_ID = OI.ORDER_ID)
inner join CPDB..SFF_ACCOUNT PBA on (OI.BILLING_ACCNT_ID = PBA.ROW_ID)
inner join CPDB..SFF_ASSET_INSTANCE PI on (PBA.ROW_ID = PI.BILLING_ACCNT_ID
and PI.MOBILE_NO = OI.MOBILE_NO and PI.CHARGE_TYPE = 'Post-paid')
inner join CPDB..SFF_ACCOUNT BA on (OI.NEW_BILLING_ACCNT_ID = BA.ROW_ID)
inner join CPDB..SFF_ASSET_INSTANCE AI on (BA.ROW_ID = AI.BILLING_ACCNT_ID
and AI.MOBILE_NO = OI.MOBILE_NO and  AI.CHARGE_TYPE = 'Pre-paid')
inner join CPDB..SFF_ASSET_SERVICE_ITEM SI on (AI.ROW_ID = SI.ASSET_INSTANCE_ID)
inner join CPDB..SFF_PRODUCT P on (SI.PRODUCT_ID = P.ROW_ID)
inner join #PM_MAP_NETWORK_TYPE N on (P.NETWORK_TYPE = N.NETWORK_TYPE)
where O.ORDER_TYPE = 'Convert Postpaid to Prepaid'
and O.STATUS_DT = '20160615'
and O.STATUS_CD = 'Completed'
and O.COMPLETED_DT is not null

drop table #PM_MAP_NETWORK_TYPE

go
" > ${SCRIPT}

# Call procedure PM_S_TX_LOAD_PM_BATCH_CONVERT_POST_PRE_FROM_SFF
${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_LOAD_PM_BATCH_CONVERT_POST_PRE_FROM_SFF @order_id=${ORDER_ID}
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
echo -e "from PM_BATCH_CONVERT_POST_PRE C"  >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (C.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and C.BILLING_SYSTEM = 'BOS'" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_BATCH_CONVERT_POST_PRE with BILLING_SYSTEM=BOS: ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

# Call procedure PM_S_TX_PROCESS_CONVERT_POST_TO_PRE
${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_PROCESS_CONVERT_POST_TO_PRE @order_id=${ORDER_ID}
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
echo -e "from PM_BATCH_CONVERT_POST_PRE C"  >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (C.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "and STATUS = 'SC'" >> ${SCRIPT}
echo -e "and EXCESS_BAL_ID = NULL" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_BATCH_CONVERT_POST_PRE with STATUS=SC,EXCESS_BAL_ID=NULL : ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_BATCH_CONVERT_POST_PRE C"  >> ${SCRIPT}
echo -e "inner join PM_PREPAID_LOAD_BATCH B on (C.BATCH_ID = B.BATCH_ID)" >> ${SCRIPT}
echo -e "inner join PM_TOPUP_TRANSACTION T on (C.TOPUP_ID = T.TOPUP_ID)" >> ${SCRIPT}
echo -e "where B.ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_TOPUP_TRANSACTION : ${COUNT}"
if [ "$COUNT" -ne "0" ]; then
  exit $RET_FAIL
fi

exit $RET_OK

