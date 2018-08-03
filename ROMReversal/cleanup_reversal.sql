use PMDB

go

set nocount on

declare @job_id unsigned bigint
declare @version_id unsigned bigint
declare @template_code varchar(200)
declare @file_name varchar(200)
declare @order_id unsigned bigint
declare @run_date char(8)
declare @batch_id unsigned bigint
declare @loop int

select @template_code = 'PE_ROM_REVERSAL'
, @run_date = '20160616'
, @file_name = 'BOSRVS_20160616161616.dat'
, @loop = 1

select @job_id = JOB_ID from PM_JOB_SCHEDULER_MAPPING where TEMPLATE_CODE = @template_code

declare @bank_code     unsigned bigint
declare @category_code unsigned bigint

select @bank_code = BANK_CODE from PM_BANK where BANK_ABBR = 'ROM'
select @category_code = CATEGORY_CODE from PM_PAYMENT_CATEGORY where CATEGORY_ABBR = 'RM'


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
    delete PM_CREDIT_NOTE
    from PM_CREDIT_NOTE C
    inner join PM_BATCH_RVS_CREDIT_NOTE RC on (RC.CN_ID = C.CN_ID and RC.CN_DATE = C.CN_DATE)
    inner join PM_BATCH_RVS R on (RC.RVS_ID = R.RVS_ID)
    inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
    where B.ORDER_ID = @order_id
    and C.CN_DATE = @run_date

    delete PM_BATCH_RVS_CREDIT_NOTE
    from PM_BATCH_RVS_CREDIT_NOTE RC
    inner join PM_BATCH_RVS B on (RC.RVS_ID = B.RVS_ID)
    inner join PM_PREPAID_LOAD_BATCH L on (B.BATCH_ID = L.BATCH_ID)
    where L.ORDER_ID = @order_id

    delete PM_BATCH_RVS
    from PM_BATCH_RVS B
    inner join PM_PREPAID_LOAD_BATCH L on (B.BATCH_ID = L.BATCH_ID)
    where L.ORDER_ID = @order_id

    delete PM_INF_BATCH_HT
    from PM_INF_BATCH_HT I
    where I.ORDER_ID = @order_id

    delete PM_INF_BATCH_RVS_D
    from PM_INF_BATCH_RVS_D I
    where I.ORDER_ID = @order_id

    delete PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE
    from PM_PREPAID_BATCH_RECONCILE_DIFF_TABLE T
    inner join PM_PREPAID_BATCH_RECONCILE_DIFF D on (T.DIFF_ID = D.DIFF_ID)
    inner join PM_PREPAID_BATCH_RECONCILE R on (D.BATCH_RCC_ID = R.BATCH_RCC_ID)
    inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
    where B.ORDER_ID = @order_id

    delete PM_PREPAID_BATCH_RECONCILE_DIFF
    from PM_PREPAID_BATCH_RECONCILE_DIFF D
    inner join PM_PREPAID_BATCH_RECONCILE R on (D.BATCH_RCC_ID = R.BATCH_RCC_ID)
    inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
    where B.ORDER_ID = @order_id

    delete PM_PREPAID_BATCH_RECONCILE
    from PM_PREPAID_BATCH_RECONCILE R
    inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
    where B.ORDER_ID = @order_id

    delete PM_PREPAID_LOAD_BATCH_REJECT
    from PM_PREPAID_LOAD_BATCH_REJECT R
    inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
    where B.ORDER_ID = @order_id  

    delete PM_PREPAID_LOAD_BATCH
    from PM_PREPAID_LOAD_BATCH B
    where B.ORDER_ID = @order_id

    delete PM_JOB_ORDER
    from PM_JOB_ORDER
    where ORDER_ID = @order_id

    select @loop = 1
  end

end

delete from PM_CFG_DOC_GEN where COMPANY_ID = (
select COMPANY_ID from PM_COMPANY where COMPANY_CODE = 'Z'
)

delete from PM_CREDIT_NOTE
where CN_DATE = dateadd(dd, -1, @run_date)
and BANK_CODE = @bank_code
and CATEGORY_CODE = @category_code

go

