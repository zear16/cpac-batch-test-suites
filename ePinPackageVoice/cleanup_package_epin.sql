use PMDB

go

set nocount on

delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test ePin Normal Package Voice'
delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test ePin Normal Package Data'
delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test ePin Inactive Package Voice'
delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test ePin Inactive Package Data'
delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test ePin Not Topup Package Voice'
delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test ePin Not Topup Package Data'

go

