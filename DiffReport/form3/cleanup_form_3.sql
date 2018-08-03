use PMDB

go

declare @order_id unsigned bigint

select @order_id = O.ORDER_ID
from PM_JOB_ORDER O
inner join PM_REPORT_ORDER R on (O.ORDER_ID = R.ORDER_ID)
where O.USER_NAME = 'SUYADA'
and O.TEMPLATE_CODE = 'REPORT'
and R.REPORT_CODE = 'PMRRP406'


delete from PM_REPORT_ORDER where ORDER_ID = @order_id

delete from PM_JOB_ORDER where ORDER_ID = @order_id

go

