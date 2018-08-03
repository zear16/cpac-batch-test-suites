ORDER_ID=$(cat ${WORKING_PATH}/order_id)

# Expected OK

# Call procedure PM_S_TX_LOAD_PM_INF_PLUGIN_CREDIT_NOTE_FROM_ADJUST_TRANS
${EXECUTE_PATH}/call_sproc -c ${CONFIG_NAME} PM_S_TX_LOAD_PM_INF_PLUGIN_CREDIT_NOTE_FROM_ADJUST_TRANS @order_id=${ORDER_ID}
RET=$?
if [ $RET -ne 0 ]; then
  exit $RET_FAIL
fi

echo "order_id = ${ORDER_ID}"

exit $RET_OK

