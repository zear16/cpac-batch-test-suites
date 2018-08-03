use PMDB

go

set nocount on

declare @job_id        unsigned bigint
declare @version_id    unsigned bigint
declare @template_code varchar(200)
declare @file_name     varchar(200)
declare @order_id      unsigned bigint
declare @run_date      date
declare @batch_id      unsigned bigint
declare @category_code unsigned bigint
declare @loop          int
declare @backward      int

select @backward = convert(int,FIELD1_VALUE)
from PM_SYSTEM_ATTRIBUTE_DTL
where ATTRIBUTE_CODE = 'CPAC_PARAM'
and DB_VALUE = 'QUERY_RECHARGE_PERIOD'

select @template_code = 'PE_DCB_PURCHASE_CWDC1'
, @run_date = dateadd(mm, -@backward, getdate())
, @file_name = 'flexiPricePaidTransactionService_20140526_1111_DCBcwdc1google_20140526111201.dat'
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

    delete PM_CREDIT_NOTE_PAYMENT
    from PM_CREDIT_NOTE_PAYMENT P
    inner join PM_CREDIT_NOTE C on (C.CN_ID = P.CN_ID and C.CN_DATE = P.CN_DATE)
    inner join PM_BATCH_DCB_CREDIT_NOTE BC on (BC.CN_ID = C.CN_ID and BC.CN_DATE = C.CN_DATE)
    inner join PM_BATCH_DCB B on (B.DCB_ID = BC.DCB_ID)
    inner join PM_PREPAID_LOAD_BATCH L on (B.BATCH_ID = L.BATCH_ID)
    where L.ORDER_ID = @order_id

    delete PM_CREDIT_NOTE_ADDR
    from PM_CREDIT_NOTE_ADDR P
    inner join PM_CREDIT_NOTE C on (C.CN_ID = P.CN_ID and C.CN_DATE = P.CN_DATE)
    inner join PM_BATCH_DCB_CREDIT_NOTE BC on (BC.CN_ID = C.CN_ID and BC.CN_DATE = C.CN_DATE)
    inner join PM_BATCH_DCB B on (B.DCB_ID = BC.DCB_ID)
    inner join PM_PREPAID_LOAD_BATCH L on (B.BATCH_ID = L.BATCH_ID)
    where L.ORDER_ID = @order_id

    delete PM_CREDIT_NOTE_DTL
    from PM_CREDIT_NOTE_DTL P
    inner join PM_CREDIT_NOTE C on (C.CN_ID = P.CN_ID and C.CN_DATE = P.CN_DATE)
    inner join PM_BATCH_DCB_CREDIT_NOTE BC on (BC.CN_ID = C.CN_ID and BC.CN_DATE = C.CN_DATE)
    inner join PM_BATCH_DCB B on (B.DCB_ID = BC.DCB_ID)
    inner join PM_PREPAID_LOAD_BATCH L on (B.BATCH_ID = L.BATCH_ID)
    where L.ORDER_ID = @order_id

    delete PM_CREDIT_NOTE
    from PM_CREDIT_NOTE C
    inner join PM_BATCH_DCB_CREDIT_NOTE BC on (BC.CN_ID = C.CN_ID and BC.CN_DATE = C.CN_DATE)
    inner join PM_BATCH_DCB B on (B.DCB_ID = BC.DCB_ID)
    inner join PM_PREPAID_LOAD_BATCH L on (B.BATCH_ID = L.BATCH_ID)
    where L.ORDER_ID = @order_id

    delete PM_BATCH_DCB_CREDIT_NOTE
    from PM_BATCH_DCB_CREDIT_NOTE BC
    inner join PM_BATCH_DCB B on (BC.DCB_ID = B.DCB_ID)
    inner join PM_PREPAID_LOAD_BATCH L on (B.BATCH_ID = L.BATCH_ID)
    where L.ORDER_ID = @order_id

    delete PM_BATCH_DCB
    from PM_BATCH_DCB B
    inner join PM_PREPAID_LOAD_BATCH L on (B.BATCH_ID = L.BATCH_ID)
    where L.ORDER_ID = @order_id

    delete PM_INF_BATCH_DCB
    from PM_INF_BATCH_DCB I
    where I.ORDER_ID = @order_id

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

select @category_code = CATEGORY_CODE from PM_PAYMENT_CATEGORY where CATEGORY_ABBR = 'MP'

delete from PM_CREDIT_NOTE where CN_DATE = @run_date and CATEGORY_CODE = @category_code

go

