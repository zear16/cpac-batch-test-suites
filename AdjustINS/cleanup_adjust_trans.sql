use PMDB

go

set nocount on

delete from PM_ADJUST_TRANSACTION where convert(date,CREATED) = '20160615'

delete from PM_ADJUST_TRANSACTION where SO_NBR = 'Unit Test Adjust INS Reconcile Amount'
delete from PM_ADJUST_TRANSACTION where SO_NBR = 'Unit Test Adjust INS Reconcile Validity'
delete from PM_ADJUST_TRANSACTION where SO_NBR = 'Unit Test Adjust INS Reconcile Both'

go

