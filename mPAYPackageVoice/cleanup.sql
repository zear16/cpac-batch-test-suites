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

select @template_code = 'PE_MPAY_PACKAGE_VOICE'
, @run_date = '20160616'
, @file_name = 'PKG3G_MPAY_BOS_20160616.dat'
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

    delete PM_BATCH_PACKAGE_TOPUP
    from PM_BATCH_PACKAGE_TOPUP B
    inner join PM_PREPAID_LOAD_BATCH L on (B.BATCH_ID = L.BATCH_ID)
    where L.ORDER_ID = @order_id

    delete PM_INF_BATCH_HT
    from PM_INF_BATCH_HT I
    where I.ORDER_ID = @order_id

    delete PM_INF_BATCH_PKG_D
    from PM_INF_BATCH_PKG_D I
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

delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test Normal Package Voice'
delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test Normal Package Data'
delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test Inactive Package Voice'
delete from PM_PACKAGE where PACKAGE_NAME = 'Unit Test Not Topup Package Voice'

go

