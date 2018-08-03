use PMDB

go

set nocount on

delete from PM_REFUND_TRANSACTION where SESSION_ID = 'UnitTestTerminateRefundReconcile'
delete from PM_REFUND_TRANSACTION where SESSION_ID = 'UnitTestTerminateRefundReconcileDiff'

go

