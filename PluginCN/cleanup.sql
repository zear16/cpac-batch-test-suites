use PMDB

go

set nocount on

declare @job_id unsigned bigint
declare @version_id unsigned bigint
declare @template_code varchar(200)
declare @order_id unsigned bigint
declare @run_date char(8)
declare @batch_id unsigned bigint
declare @bos_id unsigned bigint
declare @trans_no unsigned bigint
declare @loop int


select @template_code = 'PE_PLUGIN_FILE_GEN_CN'
, @run_date = '20170116'
, @loop = 1
, @trans_no = 0

select @job_id = JOB_ID from PM_JOB_SCHEDULER_MAPPING where TEMPLATE_CODE = @template_code

while (@loop = 1)
begin

  select @loop = 0

  select @order_id = ORDER_ID from PM_JOB_ORDER
  where TEMPLATE_CODE = @template_code and RUN_DATE = @run_date
  if (@@rowcount <> 0)
  begin

    delete PM_ADJUST_TRANSACTION
    from PM_ADJUST_TRANSACTION AD
    inner join PM_INF_PLUGIN_CREDIT_NOTE_D D on (AD.ADJUST_ID = D.PP_ADJUST_ID)
    where D.ORDER_ID = @order_id

    delete from PM_INF_PLUGIN_CREDIT_NOTE_T
    where ORDER_ID = @order_id

    delete from PM_INF_PLUGIN_CREDIT_NOTE_D
    where ORDER_ID = @order_id

    delete from PM_INF_PLUGIN_CREDIT_NOTE_H
    where ORDER_ID = @order_id

    delete PM_JOB_ORDER
    from PM_JOB_ORDER
    where ORDER_ID = @order_id

    select @loop = 1
  end

end

go

