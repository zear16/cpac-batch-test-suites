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

select @template_code = 'PE_ADJUST_BOS', @run_date = '20160616'
, @file_name = 'ABC_TRAN_PPS_AIS_20160616.rpt'
, @sync_name = 'ABC_TRAN_PPS_AIS_20160616.sync'

select @job_id = JOB_ID from PM_JOB_SCHEDULER_MAPPING where TEMPLATE_CODE = @template_code

select @bos_id = BOS_ID from PM_CFG_BOS_SITE where FILE_TYPE = 'PM_ADJUST_BOS' and BOS_SITE_CODE = '1'

select @version_id = max(V.VERSION_ID) from
PM_FILE_CONFIG_VERSION V
inner join PM_FILE_CONFIG C on (C.FILE_CONFIG_ID = V.FILE_CONFIG_ID)
where C.TEMPLATE_CODE = @template_code

update PM_FILE_CONFIG_VERSION set EFFECTIVE_DATE = @run_date

select @order_id = ORDER_ID from PM_JOB_ORDER
where VERSION_ID = @version_id and FILE_NAME = @file_name
if (@@rowcount = 0)
begin

  insert into PM_JOB_ORDER
  (ORDER_TYPE, JOB_ID, TEMPLATE_CODE, ORDER_MODE, RUN_DATE, DATA_DATE_FR, DATA_DATE_TO
  , VERSION_ID, FILE_NAME, ORIGINAL_FILE_NAME, FILE_PATH, ORDER_STATUS, BOS_ID
  , SOURCE_CTRL_PATH, SOURCE_CTRL_NAME)
  values
  ('I', @job_id, @template_code, 'A', @run_date, dateadd(dd, -1, @run_date), dateadd(dd, -1, @run_date)
  , @version_id, @file_name, @file_name, '/app/payment/batch/bos1/Report/20160616', 'W', @bos_id
  , '/app/payment/batch/bos1/Report/20160616', @sync_name)

  select @order_id = @@identity

end

print '%1!', @order_id

select @batch_id = BATCH_ID from PM_PREPAID_LOAD_BATCH where ORDER_ID = @order_id
if (@@rowcount != 0)
begin

  delete from PM_ADJUST_BOS where BATCH_ID = @batch_id

end

go

