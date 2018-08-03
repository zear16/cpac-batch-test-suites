use PMDB

go

set nocount on

declare @template_code varchar(200)
declare @run_date      date
declare @order_id      unsigned bigint

select @template_code = 'CONVERT_POST_TO_PRE'
, @run_date = '20160616'

select @order_id = ORDER_ID
from PM_JOB_ORDER
where TEMPLATE_CODE = @template_code
and RUN_DATE = @run_date
if (@@rowcount = 0)
begin

  insert into PM_JOB_ORDER
  (ORDER_TYPE, TEMPLATE_CODE, ORDER_MODE, RUN_DATE
  , DATA_DATE_FR, DATA_DATE_TO, ORDER_STATUS)
  values
  ('P', @template_code, 'A', @run_date
  , dateadd(dd, -1, @run_date), dateadd(dd, -1, @run_date), 'W')

  select @order_id = @@identity

end
else
begin

  update PM_JOB_ORDER set ORDER_STATUS = 'W'
  where ORDER_ID = @order_id

end

print '%1!', @order_id

go

