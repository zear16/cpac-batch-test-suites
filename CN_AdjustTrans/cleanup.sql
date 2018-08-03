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


select @template_code = 'PE_GEN_ADJUST_CREDIT_NOTE'
, @run_date = '20161221'
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

    delete PM_CREDIT_NOTE_PRINT_ITEM
    from PM_CREDIT_NOTE_PRINT_ITEM CI
    inner join PM_CREDIT_NOTE CN on (CI.CN_ID = CN.CN_ID and CI.CN_DATE = CN.CN_DATE)
    inner join PM_ADJUST_TRANSACTION A on (CN.CN_ID = A.CN_ID and CN.CN_DATE = A.CN_DATE)
    where A.TRANS_NO = @trans_no

    delete PM_CREDIT_NOTE_POS
    from PM_CREDIT_NOTE_POS T
    inner join PM_CREDIT_NOTE CN on (T.CN_ID = CN.CN_ID and T.CN_DATE = CN.CN_DATE)
    inner join PM_ADJUST_TRANSACTION A on (CN.CN_ID = A.CN_ID and CN.CN_DATE = A.CN_DATE)
    where A.TRANS_NO = @trans_no

    delete PM_CREDIT_NOTE_PAYMENT
    from PM_CREDIT_NOTE_PAYMENT T
    inner join PM_CREDIT_NOTE CN on (T.CN_ID = CN.CN_ID and T.CN_DATE = CN.CN_DATE)
    inner join PM_ADJUST_TRANSACTION A on (CN.CN_ID = A.CN_ID and CN.CN_DATE = A.CN_DATE)
    where A.TRANS_NO = @trans_no

    delete PM_CREDIT_NOTE_MAP
    from PM_CREDIT_NOTE_MAP T
    inner join PM_CREDIT_NOTE CN on (T.CN_ID = CN.CN_ID and T.CN_DATE = CN.CN_DATE)
    inner join PM_ADJUST_TRANSACTION A on (CN.CN_ID = A.CN_ID and CN.CN_DATE = A.CN_DATE)
    where A.TRANS_NO = @trans_no

    delete PM_CREDIT_NOTE_HISTORY
    from PM_CREDIT_NOTE_HISTORY T
    inner join PM_CREDIT_NOTE CN on (T.CN_ID = CN.CN_ID and T.CN_DATE = CN.CN_DATE)
    inner join PM_ADJUST_TRANSACTION A on (CN.CN_ID = A.CN_ID and CN.CN_DATE = A.CN_DATE)
    where A.TRANS_NO = @trans_no

    delete PM_CREDIT_NOTE_DTL
    from PM_CREDIT_NOTE_DTL T
    inner join PM_CREDIT_NOTE CN on (T.CN_ID = CN.CN_ID and T.CN_DATE = CN.CN_DATE)
    inner join PM_ADJUST_TRANSACTION A on (CN.CN_ID = A.CN_ID and CN.CN_DATE = A.CN_DATE)
    where A.TRANS_NO = @trans_no

    delete PM_CREDIT_NOTE_ADDR
    from PM_CREDIT_NOTE_ADDR T
    inner join PM_CREDIT_NOTE CN on (T.CN_ID = CN.CN_ID and T.CN_DATE = CN.CN_DATE)
    inner join PM_ADJUST_TRANSACTION A on (CN.CN_ID = A.CN_ID and CN.CN_DATE = A.CN_DATE)
    where A.TRANS_NO = @trans_no

    delete PM_CREDIT_NOTE
    from PM_CREDIT_NOTE CN
    inner join PM_ADJUST_TRANSACTION A on (CN.CN_ID = A.CN_ID and CN.CN_DATE = A.CN_DATE)
    where A.TRANS_NO = @trans_no

    delete PM_ADJUST_TRANSACTION
    from PM_ADJUST_TRANSACTION A
    where A.TRANS_NO = @trans_no

    delete PM_JOB_ORDER
    from PM_JOB_ORDER
    where ORDER_ID = @order_id

    select @loop = 1
  end

end

go

