use PMDB

go

set nocount on

declare @template_code varchar(200)
declare @file_name varchar(200)
declare @order_id unsigned bigint

select @template_code = 'PE_Adjust_Validity_40_Day', @file_name = 'P0810009_99-99_20160823.txt'

select @order_id = ORDER_ID
from PM_JOB_ORDER
where TEMPLATE_CODE = @template_code
and FILE_NAME = @file_name

delete PM_JOB_ORDER
from PM_JOB_ORDER
where REF_ORDER_ID = @order_id

delete PM_ADJUST_TRANSACTION
from PM_ADJUST_TRANSACTION A
inner join PM_FILE_ADJUST F on (A.FILE_ID = F.FILE_ID)
where F.ORDER_ID = @order_id

delete PM_INF_BATCH_ADJ_VALIDITY_H
from PM_INF_BATCH_ADJ_VALIDITY_H H
where H.ORDER_ID = @order_id

delete PM_INF_BATCH_ADJ_VALIDITY_D
from PM_INF_BATCH_ADJ_VALIDITY_D H
where H.ORDER_ID = @order_id

delete PM_INF_BATCH_ADJ_VALIDITY_T
from PM_INF_BATCH_ADJ_VALIDITY_T H
where H.ORDER_ID = @order_id

delete PM_PREPAID_LOAD_BATCH_REJECT
from PM_PREPAID_LOAD_BATCH_REJECT R
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
where B.ORDER_ID = @order_id

delete PM_PREPAID_LOAD_BATCH
from PM_PREPAID_LOAD_BATCH B
where B.ORDER_ID = @order_id

delete PM_JOB_ORDER
from PM_JOB_ORDER J
where J.ORDER_ID = @order_id

go


