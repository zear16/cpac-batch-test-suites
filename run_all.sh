#!/bin/bash

export RUN_TEST_ALL=1
export TEST_ALL=0
export TEST_OK=0
export TEST_FAIL=0

TEST_SCRIPT=(
run_Recharge.sh
run_RechargeInterstella.sh
run_AdjustBOS.sh
run_AdjustINS.sh
run_Package.sh
run_PackageINS.sh
run_OthServicePurchase.sh
run_mPAYPurchaseCWDC1.sh
run_OthServiceRefund.sh
run_mPAYRefundCWDC1.sh
run_ROMTopup.sh
run_mPAYTopup.sh
run_AdjustValidity.sh
run_ROMReversal.sh
run_mPAYReversal.sh
run_ROMPackageVoice.sh
run_ROMPackageData.sh
run_mPAYPackageVoice.sh
run_mPAYPackageData.sh
run_ePinPackageVoice.sh
run_ePinPackageData.sh
run_BillTopupGSM.sh
run_BillTopupGSM-IRB.sh
run_BillTopupSME.sh
run_BillTopupSME-IRB.sh
run_PartnerTopup.sh
run_OfflineCampaign.sh
run_UFairBOS.sh
run_UFairINS.sh
run_TextFileCN.sh
run_TextFileReceipt.sh
run_ConvertPostToPre.sh
run_AdjustByFileOnline.sh
)

for script in ${TEST_SCRIPT[@]}; do
  #./${script}
  . ${script}
  rm -rf ${WORKING_PATH}
done

if [ ${RUN_TEST_ALL} -eq 1 ]; then
  echo "run all"
  echo "Test All ${TEST_ALL}"
  echo "Test OK ${TEST_OK}"
fi
