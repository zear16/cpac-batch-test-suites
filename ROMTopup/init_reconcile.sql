use PMDB

go

set nocount on

declare @job_id unsigned bigint
declare @template_code varchar(200)
declare @order_id unsigned bigint
declare @run_date char(8)
declare @batch_id unsigned bigint

select @template_code = 'PE_ROM_TOPUP_RECONCILE', @run_date = '20160616'

select @job_id = JOB_ID from PM_JOB_SCHEDULER_MAPPING where TEMPLATE_CODE = @template_code

select @order_id = ORDER_ID from PM_JOB_ORDER
where TEMPLATE_CODE = @template_code and RUN_DATE = @run_date
if (@@rowcount = 0)
begin

  insert into PM_JOB_ORDER
  (ORDER_TYPE, JOB_ID, TEMPLATE_CODE, ORDER_MODE, RUN_DATE, DATA_DATE_FR, DATA_DATE_TO, ORDER_STATUS)
  values
  ('P', @job_id, @template_code, 'A', @run_date, convert(date, @run_date, 112), convert(date, @run_date, 112), 'W')

  select @order_id = @@identity

end

print '%1!', @order_id

go

