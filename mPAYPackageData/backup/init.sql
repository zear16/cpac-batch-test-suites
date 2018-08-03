use PMDB

go

set nocount on

declare @job_id unsigned bigint
declare @version_id unsigned bigint
declare @template_code varchar(200)
declare @file_name varchar(200)
declare @order_id unsigned bigint
declare @run_date char(8)
declare @batch_id unsigned bigint
declare @package_name varchar(200)
declare @package_code unsigned bigint

select @template_code = 'PE_MPAY_PACKAGE_DATA'
, @run_date = '20160616'
, @file_name = 'GPRS3G_BOS_MPAY_20160616.dat'
, @package_name = 'Unit Test Normal Package Voice'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE, TOPUP_BOO, ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (161616, @package_name, 'V', 100, 'Y', 'Y', @run_date
   , 'unit', getdate(), 'unit', getdate())

end

select @package_name = 'Unit Test Normal Package Data'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE, TOPUP_BOO, ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (161617, @package_name, 'D', 100, 'Y', 'Y', @run_date
   , 'unit', getdate(), 'unit', getdate())

end

select @package_name = 'Unit Test Inactive Package Voice'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE, TOPUP_BOO, ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (161618, @package_name, 'V', 100, 'Y', 'N', @run_date
   , 'unit', getdate(), 'unit', getdate())

end

select @package_name = 'Unit Test Not Topup Package Voice'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE, TOPUP_BOO, ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (161619, @package_name, 'V', 100, 'N', 'Y', @run_date
   , 'unit', getdate(), 'unit', getdate())

end

select @package_name = 'Unit Test Inactive Package Data'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE, TOPUP_BOO, ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (161620, @package_name, 'D', 100, 'Y', 'N', @run_date
   , 'unit', getdate(), 'unit', getdate())

end

select @package_name = 'Unit Test Not Topup Package Data'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE, TOPUP_BOO, ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (161621, @package_name, 'D', 100, 'N', 'Y', @run_date
   , 'unit', getdate(), 'unit', getdate())

end

select @job_id = JOB_ID from PM_JOB_SCHEDULER_MAPPING where TEMPLATE_CODE = @template_code

select @version_id = max(V.VERSION_ID) from
PM_FILE_CONFIG_VERSION V
inner join PM_FILE_CONFIG C on (C.FILE_CONFIG_ID = V.FILE_CONFIG_ID)
where C.TEMPLATE_CODE = @template_code

update PM_FILE_CONFIG_VERSION set EFFECTIVE_DATE = @run_date where VERSION_ID = @version_id

select @order_id = ORDER_ID from PM_JOB_ORDER
where VERSION_ID = @version_id and FILE_NAME = @file_name and RUN_DATE = @run_date
if (@@rowcount = 0)
begin

  insert into PM_JOB_ORDER
  (ORDER_TYPE, JOB_ID, TEMPLATE_CODE, ORDER_MODE, RUN_DATE, DATA_DATE_FR, DATA_DATE_TO,
  VERSION_ID, FILE_NAME, ORIGINAL_FILE_NAME, ZIP_NAME, FILE_PATH, ORDER_STATUS)
  values
  ('I', @job_id, @template_code, 'A', @run_date, convert(date, @run_date, 112), convert(date, @run_date, 112),
  @version_id, @file_name, @file_name, null, '/opt/ais/cpac/batchprepaid/mPAY_PKG_DATA', 'W')

  select @order_id = @@identity

end

print '%1!', @order_id

delete from PM_BATCH_PACKAGE_TOPUP
from PM_BATCH_PACKAGE_TOPUP B
inner join PM_PREPAID_LOAD_BATCH L on (B.BATCH_ID = L.BATCH_ID)
where L.ORDER_ID = @order_id

delete from PM_INF_BATCH_HT where ORDER_ID = @order_id

delete from PM_INF_BATCH_PKG_D where ORDER_ID = @order_id

go

