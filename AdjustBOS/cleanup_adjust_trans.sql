use PMDB

go

set nocount on

delete from PM_ADJUST_TRANSACTION where SO_NBR = 'Unit Test Adjust BOS Reconcile Amount'
delete from PM_ADJUST_TRANSACTION where SO_NBR = 'Unit Test Adjust BOS Reconcile Validity'
delete from PM_ADJUST_TRANSACTION where SO_NBR = 'Unit Test Adjust BOS Reconcile Both'

go

