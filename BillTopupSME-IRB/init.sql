use PMDB

go

set nocount on

declare @job_id        unsigned bigint
declare @version_id    unsigned bigint
declare @template_code varchar(200)
declare @file_name     varchar(200)
declare @order_id      unsigned bigint
declare @run_date      char(8)
declare @batch_id      unsigned bigint
declare @company_id    unsigned bigint

select @template_code = 'PE_BILL_TOPUP_IRB'
, @run_date = '20160616'
, @file_name = 'SME_GV20160616.dat'

select @company_id = COMPANY_ID from PM_COMPANY where COMPANY_ABBR = 'AWN'

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
  (ORDER_TYPE, JOB_ID, TEMPLATE_CODE, ORDER_MODE, RUN_DATE, DATA_DATE_FR, DATA_DATE_TO
  , BILLING_SYSTEM, COMPANY_ID
  , VERSION_ID, FILE_NAME, ORIGINAL_FILE_NAME, FILE_PATH, ORDER_STATUS)
  values
  ('I', @job_id, @template_code, 'A', @run_date, @run_date, @run_date
  , 'BOS', @company_id
  , @version_id, @file_name, @file_name, '/app/payment/batch/bill_topup', 'W')

  select @order_id = @@identity

end

print '%1!', @order_id


go

