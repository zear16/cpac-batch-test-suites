use PMDB

go

set nocount on

declare @order_id unsigned bigint
declare @job_id unsigned bigint
declare @version_id unsigned bigint
declare @template_code varchar(200)
declare @file_name varchar(200)
declare @run_date char(8)
declare @loop int

select @template_code = 'PE_ADJUST_VALIDITY_40_DAY'
, @file_name = 'P0810009_99-99_20160823.txt'
, @run_date = '20160808'
, @loop = 1

select @job_id = JOB_ID from PM_JOB_SCHEDULER_MAPPING where TEMPLATE_CODE = @template_code

select @version_id = max(V.VERSION_ID) from
PM_FILE_CONFIG_VERSION V
inner join PM_FILE_CONFIG C on (C.FILE_CONFIG_ID = V.FILE_CONFIG_ID)
where C.TEMPLATE_CODE = @template_code

while (@loop = 1)
begin

  select @loop = 0

  select @order_id = ORDER_ID from PM_JOB_ORDER
  where VERSION_ID = @version_id and FILE_NAME = @file_name and RUN_DATE = @run_date
  if (@@rowcount <> 0)
  begin

    delete PM_ADJUST_TRANSACTION
    from PM_ADJUST_TRANSACTION T
    inner join PM_FILE_ADJUST F on (T.FILE_ID = F.FILE_ID)
    where F.ORDER_ID = @order_id

    delete PM_FILE_ADJUST
    from PM_FILE_ADJUST
    where ORDER_ID = @order_id

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

    select @loop = 1
  end

end

go


