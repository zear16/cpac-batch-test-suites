use PMDB

go

create or replace procedure _INSERT_PM_PACKAGE (
  @package_code unsigned bigint,
  @package_name univarchar(200),
  @package_type char(1),
  @package_fee  decimal(14,2),
  @bank_code    unsigned bigint
)
as

if ((select count(*) from PM_PACKAGE where PACKAGE_CODE = @package_code) = 0)
begin
  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE, BANK_CODE
  , EFFECTIVE_DATE, GEN_RECEIPT_BOO, ACTIVE_BOO
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@package_code, @package_name, @package_type, @package_fee, @bank_code
  , '20160101', 'N', 'Y'
  , 'init', getdate(), 'init', getdate())
end

go

set proc_return_status off

exec _INSERT_PM_PACKAGE 760483, '175 mPAY MaoMao 18 B, Free25Min, Exp1days', 'V', 18.0, 500
exec _INSERT_PM_PACKAGE 760484, 'โปรโทรทุกค่าย_Freedom [All Networks 0.55B] Ex.VAT', 'D', 18.0, 500
exec _INSERT_PM_PACKAGE 181601, 'Test ePin Voice Package', 'V', 16.0, 604
exec _INSERT_PM_PACKAGE 181602, 'Test ePin Data Package', 'D', 16.0, 604

go

drop procedure _INSERT_PM_PACKAGE

go


