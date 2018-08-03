use PMDB

go

set nocount on

declare @recharge_id  unsigned bigint
declare @mobile_no    varchar(20)
declare @session_id   varchar(64)
declare @receipt_date date
declare @batch_id     unsigned bigint
declare @order_id     unsigned bigint
declare @channel_id   unsigned bigint
declare @sub_bop_id   unsigned bigint
declare @backward     int
declare @yy           int
declare @mm           int
declare @loop         int
declare @payment_date date

select @mobile_no = '0854000673'
, @loop = 1
, @payment_date = '20160616'

-- ROM
select @channel_id = CHANNEL_ID
from PM_PAYMENT_CHANNEL
where CHANNEL_CODE = 'O'

-- Top Up
select @sub_bop_id = SUB_BOP_ID
from PM_SUB_BUSINESS_OF_PAYMENT
where SUB_BOP_CODE = 'PT'

select @backward = PERIOD
from PM_CFG_REVERSAL_PERIOD
where CHANNEL_ID = @channel_id
and SUB_BOP_ID = @sub_bop_id

select @receipt_date = dateadd(dd, 1 - @backward, @payment_date)

select @yy = datepart(yy,@receipt_date)
, @mm = datepart(mm,@receipt_date)

select @session_id = right(convert(char(8),@receipt_date,112),6) || '14104723456789@ROM'

print '@receipt_date=[%1!],@session_id=[%2!]', @receipt_date, @session_id

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

