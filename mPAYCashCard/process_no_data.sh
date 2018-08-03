ORDER_ID=$(cat ${WORKING_PATH}/order_id)

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "select R.RECHARGE_DATE, convert(date, R.TRANSACTION_DTM) as USER_DATE" >> ${SCRIPT}
echo -e ", R.DCC_E_TOPUP_SESSION_ID, R.MOBILE_NO" >> ${SCRIPT}
echo -e ", R.CARD_BATCH_ID, R.CARD_SERIAL_NO" >> ${SCRIPT}
echo -e ", R.RECHARGE_CHANNEL as CHARGE_TYPE, T.SOURCE_CODE as CARD_TYPE" >> ${SCRIPT}
echo -e ", isnull(T.FACE_VALUE,0), T.COMMERCE_BOO, T.SCRATCH_TYPE" >> ${SCRIPT}
#echo -e ", count(*) as TOTAL_TRANS, count(*) * isnull(T.FACE_VALUE,0) as SUM_FACE_VALUE" >> ${SCRIPT}
echo -e "from PM_RECHARGE R" >> ${SCRIPT}
echo -e "inner join PM_CASH_CARD_RECEIPT S on (R.CARD_BATCH_ID = S.CARD_BATCH_ID" >> ${SCRIPT}
echo -e " and R.CARD_SERIAL_NO = S.CARD_SERIAL_NO)" >> ${SCRIPT}
echo -e "inner join PM_SCRATCH_STOCK T on (R.CARD_BATCH_ID = T.BATCH_NO" >> ${SCRIPT}
echo -e " and T.START_SERIAL_NO = S.START_SERIAL_NO)" >> ${SCRIPT}
echo -e "left join PM_SCRATCH_TYPE ST on (T.TYPE_ID = ST.TYPE_ID" >> ${SCRIPT}
echo -e " and T.SCRATCH_TYPE = ST.SCRATCH_TYPE)" >> ${SCRIPT}
echo -e "where R.RECHARGE_DATE = '20160614'" >> ${SCRIPT}
echo -e "and R.RECHARGE_CHANNEL = 0" >> ${SCRIPT}
#echo -e "group by R.RECHARGE_DATE" >> ${SCRIPT}
#echo -e ", convert(date, R.TRANSACTION_DTM), T.FACE_VALUE, T.SOURCE_CODE, T.COMMERCE_BOO" >> ${SCRIPT}
#echo -e ", T.SCRATCH_TYPE, T.SOURCE_CODE, R.RECHARGE_CHANNEL" >> ${SCRIPT}
echo -e "order by RECHARGE_DATE, USER_DATE, FACE_VALUE" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT}

# Call procedure PM_S_TX_LOAD_PM_INF_MPAY_CASH_CARD_RECHARGE_FROM_TRANS
${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_LOAD_PM_INF_MPAY_CASH_CARD_RECHARGE_FROM_TRANS @order_id=${ORDER_ID}
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
echo -e "from PM_INF_MPAY_CASH_CARD_RECHARGE_H"  >> ${SCRIPT}
echo -e "where ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_INF_MPAY_CASH_CARD_RECHARGE_H: ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_INF_MPAY_CASH_CARD_RECHARGE_D"  >> ${SCRIPT}
echo -e "where ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_INF_MPAY_CASH_CARD_RECHARGE_D: ${COUNT}"
if [ "$COUNT" -ne "0" ]; then
  exit $RET_FAIL
fi

SCRIPT=${WORKING_PATH}/check.sql
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "declare @count int" >> ${SCRIPT}
echo -e "select @count = count(*)" >> ${SCRIPT}
echo -e "from PM_INF_MPAY_CASH_CARD_RECHARGE_T"  >> ${SCRIPT}
echo -e "where ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @count" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/count
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
COUNT=$(cat ${WORKING_PATH}/count)
echo "found PM_INF_MPAY_CASH_CARD_RECHARGE_T: ${COUNT}"
if [ "$COUNT" -ne "1" ]; then
  exit $RET_FAIL
fi

${EXECUTE_PATH}/prepaid_loader -c ${CONFIG_NAME} --order-id ${ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

if [ ! -f "${EXPORT_PATH}/${EXPORT_SYNC_FILE}" ]; then
  echo "${EXPORT_PATH}/${EXPORT_SYNC_FILE} not found"
  exit $RET_FAIL
fi

if [ ! -f "${EXPORT_PATH}/${EXPORT_DATA_FILE}" ]; then
  echo "${EXPORT_PATH}/${EXPORT_DATA_FILE} not found"
  exit $RET_FAIL
fi

# Create Header of compare file
echo -e "use PMDB" > ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}
echo -e "set nocount on" >> ${SCRIPT}
echo -e "\ndeclare @extract_dt char(14)" >> ${SCRIPT}
echo -e "select @extract_dt = " >> ${SCRIPT}
echo -e "str_replace(" >> ${SCRIPT}
echo -e "str_replace(" >> ${SCRIPT}
echo -e "str_replace(convert(char(19),EXTRACT_DT,23),'-',null),'T',null),':',null)" >> ${SCRIPT}
echo -e "from PM_INF_MPAY_CASH_CARD_RECHARGE_H" >> ${SCRIPT}
echo -e "where ORDER_ID = ${ORDER_ID}" >> ${SCRIPT}
echo -e "\nprint '%1!', @extract_dt" >> ${SCRIPT}
echo -e "\ngo" >> ${SCRIPT}

isql -U${USER} -P${PASS} -S${SERVER} -i ${SCRIPT} > ${WORKING_PATH}/extract_dt
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi
EXTRACT_DT=$(cat ${WORKING_PATH}/extract_dt)

echo -e "H|${EXTRACT_DT}|10016" > ${WORKING_PATH}/compare
echo -e "T||0|0|0" >> ${WORKING_PATH}/compare

DIFF=$(diff ${EXPORT_PATH}/${EXPORT_DATA_FILE} ${WORKING_PATH}/compare)
if [ "${DIFF}" != "" ]; then
  echo "${DIFF}"
  exit $RET_FAIL
fi

exit $RET_OK

