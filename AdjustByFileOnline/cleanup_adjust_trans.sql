use PMDB

go

set nocount on

declare @run_date      date
declare @template_code varchar(64)

select @template_code = 'UNIT_ADJ_BY_FILE_ONL'
, @run_date = '20160616'

delete PM_ADJUST_TRANSACTION
from PM_JOB_ORDER J
inner join PM_FILE_ADJUST F on (J.ORDER_ID = F.ORDER_ID)
inner join PM_ADJUST_TRANSACTION A on (F.FILE_ID = A.FILE_ID)
where J.RUN_DATE = @run_date
and J.TEMPLATE_CODE = @template_code

delete PM_FILE_ADJUST
from PM_JOB_ORDER J
inner join PM_FILE_ADJUST F on (J.ORDER_ID = F.ORDER_ID)
where J.RUN_DATE = @run_date
and J.TEMPLATE_CODE = @template_code

delete PM_PREPAID_LOAD_BATCH
from PM_JOB_ORDER J
inner join PM_PREPAID_LOAD_BATCH B on (J.ORDER_ID = B.ORDER_ID)
where J.RUN_DATE = @run_date
and J.TEMPLATE_CODE = @template_code

delete from PM_JOB_ORDER
where RUN_DATE = @run_date
and TEMPLATE_CODE = @template_code

go

