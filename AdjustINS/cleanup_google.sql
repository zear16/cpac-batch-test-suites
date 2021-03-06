use PMDB

go

set nocount on

declare @template_code varchar(200)

select @template_code = 'PE_DCB_REFUND_CWDC1'

delete from PM_FILE_ADJUST where FILE_NAME = 'Unit Test Adjust BOS reconcile with Google'

delete from PM_BATCH_DCB where TRANSACTION_ID = '201606161616160000'

delete from PM_BATCH_DCB where TRANSACTION_ID = '201606161616160001'

delete PM_PREPAID_LOAD_BATCH
from PM_PREPAID_LOAD_BATCH L
inner join PM_JOB_ORDER J on (L.ORDER_ID = J.ORDER_ID)
where J.RUN_DATE = '20160615'
and J.FILE_NAME = 'Unit Test Adjust BOS'
and J.TEMPLATE_CODE = @template_code

delete PM_JOB_ORDER
from PM_JOB_ORDER J
where J.RUN_DATE = '20160615'
and J.FILE_NAME = 'Unit Test Adjust BOS'
and J.TEMPLATE_CODE = @template_code

go


