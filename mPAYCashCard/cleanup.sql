use PMDB

go

set nocount on

go


declare curs cursor
for select ORDER_ID from PM_JOB_ORDER
where TEMPLATE_CODE = 'PE_MPAY_CASH_CARD_EXP'
and RUN_DATE = '20160616'

go

declare @order_id unsigned bigint
declare @run_date date

select @run_date = '20160616'

open curs
fetch curs into @order_id
while (@@sqlstatus = 0)
begin

  delete from PM_INF_MPAY_CASH_CARD_RECHARGE_H where ORDER_ID = @order_id

  delete from PM_INF_MPAY_CASH_CARD_RECHARGE_D where ORDER_ID = @order_id

  delete from PM_INF_MPAY_CASH_CARD_RECHARGE_T where ORDER_ID = @order_id

  delete PM_PREPAID_LOAD_BATCH
  from PM_JOB_ORDER O
  inner join PM_PREPAID_LOAD_BATCH B on (O.ORDER_ID = B.ORDER_ID)
  where O.ORDER_ID = @order_id

  delete from PM_JOB_ORDER where ORDER_ID = @order_id

  fetch curs into @order_id
end

go


