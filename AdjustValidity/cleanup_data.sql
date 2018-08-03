use PMDB

go

set nocount on

declare @template_code varchar(200)
declare @file_name varchar(200)

select @template_code = 'PE_Adjust_Validity_40_Day', @file_name = 'P0810009_99-99_20160823.txt'

delete PM_INF_BATCH_ADJ_VALIDITY_H
from PM_INF_BATCH_ADJ_VALIDITY_H H
inner join PM_JOB_ORDER J on (H.ORDER_ID = J.ORDER_ID)
where J.TEMPLATE_CODE = @template_code
and FILE_NAME = @file_name

delete PM_INF_BATCH_ADJ_VALIDITY_D
from PM_INF_BATCH_ADJ_VALIDITY_D H
inner join PM_JOB_ORDER J on (H.ORDER_ID = J.ORDER_ID)
where J.TEMPLATE_CODE = @template_code
and FILE_NAME = @file_name

delete PM_INF_BATCH_ADJ_VALIDITY_T
from PM_INF_BATCH_ADJ_VALIDITY_T H
inner join PM_JOB_ORDER J on (H.ORDER_ID = J.ORDER_ID)
where J.TEMPLATE_CODE = @template_code
and FILE_NAME = @file_name

delete PM_PREPAID_LOAD_BATCH_REJECT
from PM_PREPAID_LOAD_BATCH_REJECT R
inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
inner join PM_JOB_ORDER J on (B.ORDER_ID = J.ORDER_ID)
where J.TEMPLATE_CODE = @template_code
and FILE_NAME = @file_name

delete PM_PREPAID_LOAD_BATCH
from PM_PREPAID_LOAD_BATCH B
inner join PM_JOB_ORDER J on (B.ORDER_ID = J.ORDER_ID)
where J.TEMPLATE_CODE = @template_code
and FILE_NAME = @file_name

delete PM_JOB_ORDER
from PM_JOB_ORDER J
where J.TEMPLATE_CODE = @template_code
and FILE_NAME = @file_name

go


