use PMDB

go

set nocount on

declare @job_id        unsigned bigint
declare @version_id    unsigned bigint
declare @template_code varchar(200)
declare @file_name     varchar(200)
declare @sync_name     varchar(200)
declare @order_id      unsigned bigint
declare @run_date      char(8)
declare @batch_id      unsigned bigint
declare @bos_id        unsigned bigint

declare @package_name  varchar(200)
declare @package_code  unsigned bigint

-- Init Package Not Gen Receipt

select @package_name = 'Unit Test Package with not gen receipt'

select @package_code = PACKAGE_CODE
from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  select @package_code = 6666

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE
   , ACTIVE_BOO, GEN_RECEIPT_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@package_code, @package_name, 'V', 10.00
   , 'Y', 'N', getdate()
   , 'unit', getdate(), 'unit', getdate())

end

select @template_code = 'PE_PACKAGE_INS', @run_date = '20160616'
, @file_name = 'PAL_TRAN_PPS_AWN_20160616000000_20160616235959.rpt'
, @sync_name = 'PAL_TRAN_PPS_AWN_20160616000000_20160616235959.sync'

select @job_id = JOB_ID from PM_JOB_SCHEDULER_MAPPING where TEMPLATE_CODE = @template_code

select @version_id = max(V.VERSION_ID) from
PM_FILE_CONFIG_VERSION V
inner join PM_FILE_CONFIG C on (C.FILE_CONFIG_ID = V.FILE_CONFIG_ID)
where C.TEMPLATE_CODE = @template_code

update PM_FILE_CONFIG_VERSION set EFFECTIVE_DATE = @run_date where VERSION_ID = @version_id

select @order_id = ORDER_ID from PM_JOB_ORDER
where VERSION_ID = @version_id and FILE_NAME = @file_name
if (@@rowcount = 0)
begin

  insert into PM_JOB_ORDER
  (ORDER_TYPE, JOB_ID, TEMPLATE_CODE, ORDER_MODE, RUN_DATE, DATA_DATE_FR, DATA_DATE_TO
  , VERSION_ID, FILE_NAME, ORIGINAL_FILE_NAME, FILE_PATH, ORDER_STATUS
  , BILLING_SYSTEM, BOS_ID, SOURCE_CTRL_PATH, SOURCE_CTRL_NAME)
  values
  ('I', @job_id, @template_code, 'A', @run_date, @run_date, @run_date
  , @version_id, @file_name, @file_name, '/app/payment/batch/ins/package/20160616', 'W'
  , 'INS', @bos_id, '/app/payment/batch/ins/package/20160616', @sync_name)

  select @order_id = @@identity

end

print '%1!', @order_id

select @batch_id = BATCH_ID from PM_PREPAID_LOAD_BATCH where ORDER_ID = @order_id
if (@@rowcount != 0)
begin

  delete from PM_PACKAGE_BOS where BATCH_ID = @batch_id

end

go

