if [ -f "${INTERFACE_NAME}/env.sh" ]; then
  . ${INTERFACE_NAME}/env.sh
fi

for opts in ${TEST_CASE[@]}; do
  opt=(${opts//:/ })
  case=${opt[0]}
  expected=${opt[1]}
  if [ "${TEST_FAIL}" -eq 0 ]; then
    echo "test ${INTERFACE_NAME} case ${case} expected ${expected}"
    export TEST_EXPECTED=${expected}
    unit_test $INTERFACE_NAME $case $expected
  fi
done

if [ ${RUN_TEST_ALL} -eq 0 ]; then
  rm -rf ${WORKING_PATH}
  echo "Test All ${TEST_ALL}"
  echo "Test OK ${TEST_OK}"
fi

