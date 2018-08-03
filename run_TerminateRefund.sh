#!/bin/bash

. common/env.sh
. common/prepare.sh

# Start Here

export EXECUTE=call_sproc
export INTERFACE_NAME=TerminateRefund

TEST_CASE=(
reconcile_diff_credit_note:0
reconcile_diff_refund_trans:0
reconcile_diff_mismatch_credit_note:0
reconcile_diff_mismatch_refund_trans:0
reconcile_not_diff:0
)

# End Here

. common/execute.sh

