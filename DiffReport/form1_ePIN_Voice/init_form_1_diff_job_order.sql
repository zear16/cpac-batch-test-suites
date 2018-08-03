use PMDB

go

declare @order_id unsigned bigint

select @order_id = O.ORDER_ID
from PM_JOB_ORDER O 
where O.TEMPLATE_CODE = 'PE_EPIN_PACKAGE_VOICE'
and O.RUN_DATE = '20170125'
and O.ORDER_TYPE = 'I'

update PM_JOB_ORDER
set ORDER_STATUS = 'W'
, EXPIRY_DTM = dateadd(dd, 1, getdate())
where ORDER_ID = @order_id

update PM_PREPAID_LOAD_BATCH
set BATCH_STATE = 'R', PROCESS_STATUS = 'WT'
where ORDER_ID = @order_id

print '@order_id = %1!', @order_id

go

