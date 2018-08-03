use PMDB

go

set nocount on

delete from PM_ADJUST_TRANSACTION where SO_NBR = 'Unit Test Adjust Wrong Number'
delete from PM_ADJUST_TRANSACTION where SO_NBR = 'Unit Test Adjust Wrong Number 1'
delete from PM_ADJUST_TRANSACTION where SO_NBR = 'Unit Test Adjust Wrong Number 2'
delete from PM_ADJUST_TRANSACTION where SO_NBR = 'Unit Test Adjust Wrong Number 3'

go

