use PMDB

go

set nocount on

declare @bank_code unsigned bigint
declare @package_name varchar(200)
declare @package_code unsigned bigint
declare @run_date char(8)

select @run_date = '20160616'

select @bank_code = BANK_CODE from PM_BANK where BANK_ABBR = 'MPM'

select @package_name = 'Unit Test mPAY Normal Package Voice'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE, BANK_CODE
   -- , TOPUP_BOO
  , GEN_RECEIPT_BOO
   , ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (170000, @package_name, 'V', 100, @bank_code
   -- , 'Y'
  , 'N'
   , 'Y', @run_date
   , 'unit', getdate(), 'unit', getdate())

end

select @package_name = 'Unit Test mPAY Normal Package Data'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE, BANK_CODE
   -- , TOPUP_BOO
  , GEN_RECEIPT_BOO
   , ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (170001, @package_name, 'D', 100, @bank_code
   -- , 'Y'
  , 'N'
   , 'Y', @run_date
   , 'unit', getdate(), 'unit', getdate())

end

select @package_name = 'Unit Test mPAY Inactive Package Voice'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE, BANK_CODE
   -- , TOPUP_BOO
  , GEN_RECEIPT_BOO
   , ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (170002, @package_name, 'V', 100, @bank_code
   -- , 'Y'
  , 'N'
   , 'N', @run_date
   , 'unit', getdate(), 'unit', getdate())

end

select @package_name = 'Unit Test mPAY Inactive Package Data'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE, BANK_CODE
   -- , TOPUP_BOO
  , GEN_RECEIPT_BOO
   , ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (170003, @package_name, 'D', 100, @bank_code
   -- , 'Y'
  , 'N'
   , 'N', @run_date
   , 'unit', getdate(), 'unit', getdate())

end

select @package_name = 'Unit Test mPAY Not Topup Package Voice'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE, BANK_CODE
   -- , TOPUP_BOO
  , GEN_RECEIPT_BOO
   , ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (170004, @package_name, 'V', 100, @bank_code
   -- , 'N'
  , 'N'
   , 'Y', @run_date
   , 'unit', getdate(), 'unit', getdate())

end

select @package_name = 'Unit Test mPAY Not Topup Package Data'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE, BANK_CODE
   -- , TOPUP_BOO
  , GEN_RECEIPT_BOO
   , ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (170005, @package_name, 'V', 100, @bank_code
   -- , 'N'
  , 'N'
   , 'Y', @run_date
   , 'unit', getdate(), 'unit', getdate())

end

go

