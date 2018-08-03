use PMDB

go

set nocount on

declare @job_id        unsigned bigint
declare @version_id    unsigned bigint
declare @template_code varchar(200)
declare @file_name     varchar(200)
declare @order_id      unsigned bigint
declare @run_date      char(8)
declare @batch_id      unsigned bigint
declare @bos_id        unsigned bigint
declare @loop          int

select @template_code = 'PE_RECHARGE_INS'
, @run_date = '20160616'
, @file_name = 'RH_TRAN_PPS_AWN_201606160000_20160616235959.rpt'
, @loop = 1

select @job_id = JOB_ID from PM_JOB_SCHEDULER_MAPPING where TEMPLATE_CODE = @template_code

-- select @bos_id = BOS_ID from PM_CFG_BOS_SITE where FILE_TYPE = 'PM_RECHARGE' and BOS_SITE_CODE = '1'

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

    delete PM_RECHARGE_GEN_RECEIPT_STATE
    from PM_RECHARGE_GEN_RECEIPT_STATE S
    inner join PM_PREPAID_LOAD_BATCH B on (S.BATCH_ID = B.BATCH_ID)
    where B.ORDER_ID = @order_id

    delete PM_RECHARGE_REWARD
    from PM_RECHARGE_REWARD W
    inner join PM_RECHARGE R on (W.RECHARGE_ID = R.RECHARGE_ID)
    inner join PM_PREPAID_LOAD_BATCH B on (R.BATCH_ID = B.BATCH_ID)
    where B.ORDER_ID = @order_id

    delete PM_RECHARGE
    from PM_RECHARGE R
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

update PM_SYSTEM_ATTRIBUTE_DTL
set FIELD1_VALUE = '10000'
where ATTRIBUTE_CODE = 'PREPAID_THRESHOLD'
and DB_VALUE = 'PE_RECHARGE_INS'

go

