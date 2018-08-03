use PMDB

go

set nocount on

declare @recharge_id unsigned bigint
declare @mobile_no varchar(20)
declare @session_id varchar(64)
declare @receipt_date char(8)
declare @batch_id unsigned bigint
declare @order_id unsigned bigint
declare @backward int
declare @yy int
declare @mm int
declare @loop int

select @mobile_no = '0854000673'
, @loop = 1

select @backward = convert(int,FIELD1_VALUE)
from PM_SYSTEM_ATTRIBUTE_DTL
where ATTRIBUTE_CODE = 'CPAC_PARAM'
and DB_VALUE = 'QUERY_RECHARGE_PERIOD'

select @yy = datepart(yy,dateadd(mm,-@backward,getdate()))
, @mm = datepart(mm,dateadd(mm,-@backward,getdate()))

select @receipt_date = convert(char(4),@yy) ||
right(replicate('0',2)+convert(varchar(2),@mm),2) || '01'

select @session_id = right(@receipt_date,6) || '14104723456789@ROM'

while (@loop = 1)
begin

  select @loop = 0

  select @recharge_id = RECHARGE_ID, @batch_id = BATCH_ID 
  from PM_RECHARGE
  where RECHARGE_DATE = @receipt_date
  and MOBILE_NO = @mobile_no
  and DCC_E_TOPUP_SESSION_ID = @session_id
  if (@@rowcount != 0)
  begin
    select @loop = 1

    select @order_id = ORDER_ID from PM_PREPAID_LOAD_BATCH where BATCH_ID = @batch_id

    delete from PM_RECHARGE
    where RECHARGE_DATE = @receipt_date and RECHARGE_ID = @recharge_id

    delete from PM_PREPAID_LOAD_BATCH where BATCH_ID = @batch_id

    delete from PM_JOB_ORDER where ORDER_ID = @order_id

  end

end

go

