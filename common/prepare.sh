export WORKING_PID=$$
export WORKING_PATH=".${WORKING_PID}"
if [ -f "${WORKING_PATH}" ]; then
  rm -rf ${WORKING_PATH}
fi
mkdir -p ${WORKING_PATH}

if [ -z ${RUN_TEST_ALL} ] || [ ${RUN_TEST_ALL} -ne 1 ]; then
  export RUN_TEST_ALL=0
fi
if [ ${RUN_TEST_ALL} -eq 0 ]; then
  export TEST_ALL=0
  export TEST_OK=0
  export TEST_FAIL=0
fi

function unit_test {
  if [ ${TEST_FAIL} -ne 0 ]; then
    return
  fi
  export TEST_ALL=$(($TEST_ALL+1))
  if [ "$3" -eq "0" ]; then
    export RET_FAIL=1
    export RET_OK=0
  else
    export RET_FAIL=0
    export RET_OK=1
  fi
  export TEST_CASE_NAME=$2
  cp -rf $1/* ${WORKING_PATH}
  
  if [ -f "${WORKING_PATH}/$2.init.sh" ]; then
    ${WORKING_PATH}/$2.init.sh
  else
    if [ -f "${WORKING_PATH}/init.sh" ]; then
      ${WORKING_PATH}/init.sh
    fi
  fi
  if [ -f "${WORKING_PATH}/order_id" ]; then
    ORDER_ID=$(cat ${WORKING_PATH}/order_id)
  fi
  #ORDER_ID=$(cat ${WORKING_PATH}/order_id)
  
  if [ -f "${WORKING_PATH}/$2.process.sh" ]; then
    ${WORKING_PATH}/$2.process.sh
  else
    ${EXECUTE_PATH}/${EXECUTE} -c ${CONFIG_NAME} --order-id ${ORDER_ID}
  fi
  RET=$?
  if [ "${RET}" -eq "$3" ]; then

    CHECK_ERROR=0

    # Cross check
    if [ -f "${WORKING_PATH}/$2.csv" ]; then
      ${EXECUTE_PATH}/vdb -db ${SERVER} -u ${USER} -p ${PASS} -id ${WORKING_PATH}/order_id -dat ${WORKING_PATH}/$2.csv
      RET=$?
      if [ "${RET}" -ne "0" ]; then
        CHECK_ERROR=1
      fi
    fi

    if [ "${CHECK_ERROR}" -ne "0" ]; then
      echo "test $1 case $2 Failed: expected $3 return $RET"
      export TEST_FAIL=$((${TEST_FAIL}+1))
    else
      CSV_LIST=$(ls ${WORKING_PATH}/$2.[0-9]*.csv 2>/dev/null | xargs -n 1 basename 2>/dev/null | sort -t '.' -k2n)
      for csv in ${CSV_LIST[@]}; do
        ${EXECUTE_PATH}/vdb -db ${SERVER} -u ${USER} -p ${PASS} -id ${WORKING_PATH}/order_id -dat ${WORKING_PATH}/${csv}
        RET=$?
        if [ "${RET}" -ne "0" ]; then
          CHECK_ERROR=1
          break
        fi  
      done

      if [ "${CHECK_ERROR}" -ne "0" ]; then
        echo "test $1 case $2 Failed: expected $3 return $RET"
        export TEST_FAIL=$((${TEST_FAIL}+1))
      else
        export TEST_OK=$((${TEST_OK}+1))
      fi
    fi
  else
    echo "test $1 case $2 Failed: expected $3 return $RET"
    export TEST_FAIL=$((${TEST_FAIL}+1))
  fi

  if [ -f "${WORKING_PATH}/$2.cleanup.sh" ]; then
    ${WORKING_PATH}/$2.cleanup.sh
  else
    if [ -f "${WORKING_PATH}/cleanup.sh" ]; then
      ${WORKING_PATH}/cleanup.sh
    fi
  fi
}

