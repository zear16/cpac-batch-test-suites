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
declare @bank_code     unsigned bigint
declare @channel_id    unsigned bigint

select @template_code = 'PE_BANK_TOPUP'
, @run_date = '20160616'
, @file_name = 'BP_AIS_20160616_KBANK.dat'

select @job_id = JOB_ID from PM_JOB_SCHEDULER_MAPPING where TEMPLATE_CODE = @template_code

select @bank_code = BANK_CODE from PM_BANK where BANK_ABBR = 'KBANK'

select @channel_id = CHANNEL_ID from PM_PAYMENT_CHANNEL where CHANNEL_CODE = 'B'

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
  , BANK_CODE, CHANNEL_ID
  , VERSION_ID, FILE_NAME, ORIGINAL_FILE_NAME, ZIP_NAME, FILE_PATH, ORDER_STATUS)
  values
  ('I', @job_id, @template_code, 'A', @run_date, @run_date, @run_date
  , @bank_code, @channel_id
  , @version_id, @file_name, @file_name, @file_name, '/opt/ais/cpac/batchprepaid/bank_topup', 'W')

  select @order_id = @@identity

end

print '%1!', @order_id

delete from PM_BATCH_BANK_TOPUP
from PM_BATCH_BANK_TOPUP B
inner join PM_PREPAID_LOAD_BATCH L on (B.BATCH_ID = L.BATCH_ID)
where L.ORDER_ID = @order_id

delete from PM_INF_BATCH_H where ORDER_ID = @order_id

delete from PM_INF_BATCH_D where ORDER_ID = @order_id

delete from PM_INF_BATCH_T where ORDER_ID = @order_id

go

