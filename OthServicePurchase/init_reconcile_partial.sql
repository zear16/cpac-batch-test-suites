use PMDB

go

set nocount on

declare @job_id        unsigned bigint
declare @template_code varchar(200)
declare @order_id      unsigned bigint
declare @run_date      date
declare @batch_id      unsigned bigint
declare @category_code unsigned bigint
declare @backward      int

select @backward = convert(int,FIELD1_VALUE)
from PM_SYSTEM_ATTRIBUTE_DTL
where ATTRIBUTE_CODE = 'CPAC_PARAM'
and DB_VALUE = 'QUERY_RECHARGE_PERIOD'

select @template_code = 'PE_OTH_SERV_PURCHASE_RECONCILE'
, @run_date = dateadd(dd, 1, dateadd(mm, -@backward, getdate()))

select @job_id = JOB_ID from PM_JOB_SCHEDULER_MAPPING where TEMPLATE_CODE = @template_code

select @category_code = CATEGORY_CODE from PM_PAYMENT_CATEGORY where CATEGORY_ABBR = 'MP'

select @order_id = ORDER_ID from PM_JOB_ORDER
where TEMPLATE_CODE = @template_code and RUN_DATE = @run_date
if (@@rowcount = 0)
begin

  insert into PM_JOB_ORDER
  (ORDER_TYPE, JOB_ID, TEMPLATE_CODE, ORDER_MODE, RUN_DATE, DATA_DATE_FR, DATA_DATE_TO, ORDER_STATUS
  , CATEGORY_CODE)
  values
  ('I', @job_id, @template_code, 'A', @run_date, dateadd(dd, -1, @run_date), dateadd(mm, -1, @run_date), 'W'
  , @category_code)

  select @order_id = @@identity

end
else
begin

  update PM_JOB_ORDER set CATEGORY_CODE = @category_code
  , DATA_DATE_FR = dateadd(dd, -1, @run_date)
  , DATA_DATE_TO = dateadd(dd, -1, @run_date)
  where ORDER_ID = @order_id

end

print '%1!', @order_id

go

