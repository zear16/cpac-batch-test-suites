use PMDB

go

set nocount on

delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test mPAY Normal Package Voice'
delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test mPAY Normal Package Data'
delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test mPAY Inactive Package Voice'
delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test mPAY Inactive Package Data'
delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test mPAY Not Topup Package Voice'
delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test mPAY Not Topup Package Data'

go

