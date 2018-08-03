#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

EXECUTE=call_sproc
INTERFACE_NAME=SearchFIFO

TEST_CASE=(
#receipt_rom_reversal_period:0
#receipt_rom_reversal_period_in_range:0
#receipt_mpay_reversal_period:0
#receipt_mpay_reversal_period_in_range:0
#recharge_rom_reversal_period:0
recharge_rom_reversal_period_in_range:0
)

# End Here

. common/execute.sh
