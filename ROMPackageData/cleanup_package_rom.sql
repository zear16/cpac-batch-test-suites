use PMDB

go

set nocount on

delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test ROM Normal Package Voice'
delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test ROM Normal Package Data'
delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test ROM Inactive Package Voice'
delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test ROM Inactive Package Data'
delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test ROM Not Topup Package Voice'
delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test ROM Not Topup Package Data'

go

