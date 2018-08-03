use PMDB

go

set nocount on

declare @job_id              unsigned bigint
declare @version_id          unsigned bigint
declare @sync_name           varchar(200)
declare @order_id            unsigned bigint
declare @run_date            char(8)
declare @template_code       varchar(250)

declare @trans_no            unsigned bigint
declare @sub_cause_id        unsigned bigint
declare @mobile_no           varchar(20)
declare @ba_no               varchar(32)
declare @adjust_id           unsigned bigint
declare @ret_msg             varchar(250)
-- Init Adjust Transaction 

select @run_date = '20161221'
, @template_code = 'PE_GEN_ADJUST_CREDIT_NOTE'

select @order_id = ORDER_ID from PM_JOB_ORDER
where TEMPLATE_CODE = @template_code
if (@@rowcount = 0)
begin

  insert into PM_JOB_ORDER
  (ORDER_TYPE, JOB_ID, TEMPLATE_CODE, ORDER_MODE, RUN_DATE, DATA_DATE_FR, DATA_DATE_TO
  , ORDER_STATUS)
  values
  ('I', @job_id, @template_code, 'A', @run_date, dateadd(dd, -1, @run_date), dateadd(dd, -1, @run_date)
  , 'W')

  select @order_id = @@identity

  update PM_ADJUST_TRANSACTION set FILE_ID = @order_id
  where ADJUST_ID = @adjust_id

end

-- process generate credit note
execute PM_S_TX_BATCH_CREDIT_NOTE_FROM_ADJUST @order_id, @ret_msg out


print '%1!', @order_id

go

