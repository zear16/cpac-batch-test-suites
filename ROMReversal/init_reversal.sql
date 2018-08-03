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
declare @session_id    varchar(200)
declare @face_value    decimal(14,2)
declare @mobile_no     varchar(20)

select @template_code = 'PE_ROM_REVERSAL'
, @run_date = '20160616'
, @file_name = 'BOSRVS_20160616161616.dat'
, @face_value = 3.07
, @mobile_no = '0854000673'
, @session_id = 'UnitTestROMReversal'

select @job_id = JOB_ID from PM_JOB_SCHEDULER_MAPPING where TEMPLATE_CODE = @template_code

select @version_id = max(V.VERSION_ID) from
PM_FILE_CONFIG_VERSION V
inner join PM_FILE_CONFIG C on (C.FILE_CONFIG_ID = V.FILE_CONFIG_ID)
where C.TEMPLATE_CODE = @template_code

update PM_FILE_CONFIG_VERSION set EFFECTIVE_DATE = @run_date where VERSION_ID = @version_id

delete PM_JOB_ORDER where VERSION_ID = @version_id and FILE_NAME = @file_name and RUN_DATE = @run_date

declare @bank_code     unsigned bigint
declare @category_code unsigned bigint
declare @company_id    unsigned bigint

select @bank_code = BANK_CODE from PM_BANK where BANK_ABBR = 'ROM'

select @category_code = CATEGORY_CODE from PM_PAYMENT_CATEGORY where CATEGORY_ABBR = 'RM'

select @company_id = COMPANY_ID from PM_COMPANY where COMPANY_ABBR = 'AWN'

select @order_id = ORDER_ID from PM_JOB_ORDER
where VERSION_ID = @version_id and FILE_NAME = @file_name and RUN_DATE = @run_date
if (@@rowcount = 0)
begin

  insert into PM_JOB_ORDER
  (ORDER_TYPE, JOB_ID, TEMPLATE_CODE, ORDER_MODE, RUN_DATE, DATA_DATE_FR, DATA_DATE_TO
  , BANK_CODE, CATEGORY_CODE, COMPANY_ID
  , VERSION_ID, FILE_NAME, ORIGINAL_FILE_NAME, ZIP_NAME, FILE_PATH, ORDER_STATUS)
  values
  ('I', @job_id, @template_code, 'A', @run_date, dateadd(dd, -1, @run_date), dateadd(dd, -1, @run_date)
  , @bank_code, @category_code, @company_id
  , @version_id, @file_name, @file_name, @file_name, '/opt/ais/cpac/batchprepaid/ROM_RVS', 'W')

  select @order_id = @@identity

end

delete from PM_BATCH_RVS
from PM_BATCH_RVS B
inner join PM_PREPAID_LOAD_BATCH L on (B.BATCH_ID = L.BATCH_ID)
where L.ORDER_ID = @order_id

delete from PM_INF_BATCH_HT where ORDER_ID = @order_id

delete from PM_INF_BATCH_RVS_D where ORDER_ID = @order_id

select @batch_id = BATCH_ID from PM_PREPAID_LOAD_BATCH where ORDER_ID = @order_id
if (@@rowcount = 0)
begin

  insert into PM_PREPAID_LOAD_BATCH
  (ORDER_ID, PROCESS_TYPE, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@order_id, 'I', 'unit', getdate(), 'unit', getdate())

  select @batch_id = @@identity

end

delete from PM_BATCH_RVS where TRANSACTION_ID = @session_id

insert into PM_BATCH_RVS
(BATCH_ID, SEQUENCE_NO, COMPANY_ID, PAYMENT_DATE, TOPUP_MOBILE_NO, TRANSACTION_CODE
, TOPUP_AMT, REVERSAL_AMT, TRANSACTION_ID, BATCH_NO
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@batch_id, '1', @company_id, dateadd(dd, -1, @run_date), @mobile_no, 'RVS'
, @face_value, @face_value, @session_id, @session_id
, 'unit', getdate(), 'unit', getdate())

print '%1!', @order_id

go

