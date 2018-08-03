use PMDB

go

set nocount on

declare @bank_code unsigned bigint
declare @package_name varchar(200)
declare @package_code unsigned bigint
declare @run_date char(8)

select @run_date = '20160616'

select @bank_code = BANK_CODE from PM_BANK where BANK_ABBR = 'ROM'

select @package_name = 'Unit Test ROM Normal Package Voice'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE
   , GEN_RECEIPT_BOO
   , BANK_CODE, ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (160000, @package_name, 'V', 100
   , 'Y'
   , @bank_code, 'Y', @run_date
   , 'unit', getdate(), 'unit', getdate())

end

select @package_name = 'Unit Test ROM Normal Package Data'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE
   , GEN_RECEIPT_BOO
   , BANK_CODE, ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (160001, @package_name, 'D', 100
   , 'Y'
   , @bank_code, 'Y', @run_date
   , 'unit', getdate(), 'unit', getdate())

end

select @package_name = 'Unit Test ROM Inactive Package Voice'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE
   , GEN_RECEIPT_BOO
   , BANK_CODE, ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (160002, @package_name, 'V', 100
   , 'Y'
   , @bank_code, 'N', @run_date
   , 'unit', getdate(), 'unit', getdate())

end

select @package_name = 'Unit Test ROM Inactive Package Data'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE
   , GEN_RECEIPT_BOO
   , BANK_CODE, ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (160003, @package_name, 'D', 100
   , 'Y'
   , @bank_code, 'N', @run_date
   , 'unit', getdate(), 'unit', getdate())

end

/*
select @package_name = 'Unit Test ROM Not Topup Package Voice'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE, BANK_CODE, TOPUP_BOO, ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (160004, @package_name, 'V', 100, @bank_code, 'N', 'Y', @run_date
   , 'unit', getdate(), 'unit', getdate())

end
*/

/*
select @package_name = 'Unit Test ROM Not Topup Package Data'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE, BANK_CODE, TOPUP_BOO, ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (160005, @package_name, 'D', 100, @bank_code, 'N', 'Y', @run_date
   , 'unit', getdate(), 'unit', getdate())

end
*/

go

