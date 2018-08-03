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

select @template_code = 'PE_RECHARGE_INS'
, @run_date = '20160616'
, @file_name = 'RH_TRAN_PPS_AWN_201606160000_20160616235959.rpt'
, @sync_name = 'RH_TRAN_PPS_AWN_201606160000_20160616235959.sync'

-- select @job_id = JOB_ID from PM_JOB_SCHEDULER_MAPPING where TEMPLATE_CODE = @template_code
select @job_id = null

-- select @bos_id = BOS_ID from PM_CFG_BOS_SITE where FILE_TYPE = 'PM_RECHARGE' and BOS_SITE_CODE = '1'

select @version_id = max(V.VERSION_ID) from
PM_FILE_CONFIG_VERSION V
inner join PM_FILE_CONFIG C on (C.FILE_CONFIG_ID = V.FILE_CONFIG_ID)
where C.TEMPLATE_CODE = @template_code

update PM_FILE_CONFIG_VERSION set
EFFECTIVE_DATE = '20160616' 
, EXPIRY_DATE = NULL 
where VERSION_ID = @version_id

select @order_id = ORDER_ID from PM_JOB_ORDER
where VERSION_ID = @version_id and FILE_NAME = @file_name and RUN_DATE = @run_date
if (@@rowcount = 0)
begin

  insert into PM_JOB_ORDER
  (ORDER_TYPE, JOB_ID, TEMPLATE_CODE, ORDER_MODE, RUN_DATE, DATA_DATE_FR, DATA_DATE_TO
  , VERSION_ID, FILE_NAME, ORIGINAL_FILE_NAME, FILE_PATH, ORDER_STATUS, BOS_ID
  , SOURCE_CTRL_PATH, SOURCE_CTRL_NAME, BILLING_SYSTEM)
  values
  ('I', @job_id, 'PE_RECHARGE_INS', 'A', @run_date, convert(date, @run_date, 112), convert(date, @run_date, 112)
  , @version_id, @file_name, @file_name, '/app/payment/batch/ins/recharge/20160616', 'W', @bos_id
  , '/app/payment/batch/ins/recharge/20160616', @sync_name, 'INS')

  select @order_id = @@identity

end

print '%1!', @order_id

select @batch_id = BATCH_ID from PM_PREPAID_LOAD_BATCH where ORDER_ID = @order_id
if (@@rowcount != 0)
begin

  delete PM_RECHARGE_REWARD
  from PM_RECHARGE_REWARD RR inner join PM_RECHARGE R on (RR.RECHARGE_ID = R.RECHARGE_ID)
  where R.BATCH_ID = @batch_id

  delete from PM_RECHARGE where BATCH_ID = @batch_id

  delete from PM_RECHARGE_GEN_RECEIPT_STATE where TRANSACTION_DT = convert(date, @run_date, 112)

end

update PM_SYSTEM_ATTRIBUTE_DTL
set FIELD1_VALUE = '1'
where ATTRIBUTE_CODE = 'PREPAID_THRESHOLD'
and DB_VALUE = 'PE_RECHARGE_INS'

go

