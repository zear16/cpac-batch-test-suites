use PMDB

go

set nocount on

declare @recharge_id   unsigned bigint
declare @mobile_no     varchar(20)
declare @recharge_date char(8)
declare @face_value    decimal(14,2)
declare @session_id    varchar(64)
declare @batch_id      unsigned bigint
declare @order_id      unsigned bigint
declare @loop          int

select @mobile_no = '0812038420'
, @recharge_date = '20160616'
, @face_value = 307
, @session_id = '16161616161616161616@BANK'
, @loop = 1

while (@loop = 1)
begin

  select @loop = 0

  select @recharge_id = RECHARGE_ID, @batch_id = BATCH_ID 
  from PM_RECHARGE
  where RECHARGE_DATE = @recharge_date
  and TRANSACTION_ID = '16161616'
  --and MOBILE_NO = @mobile_no
  --and DCC_E_TOPUP_SESSION_ID = @session_id
  if (@@rowcount != 0)
  begin
    select @loop = 1

    select @order_id = ORDER_ID from PM_PREPAID_LOAD_BATCH where BATCH_ID = @batch_id

    delete from PM_RECHARGE
    where RECHARGE_DATE = @recharge_date and RECHARGE_ID = @recharge_id

    delete from PM_PREPAID_LOAD_BATCH where BATCH_ID = @batch_id

    delete from PM_JOB_ORDER where ORDER_ID = @order_id

  end

end

declare @bank_code unsigned bigint

select @bank_code = BANK_CODE from PM_BANK where BANK_ABBR = 'KBANK'

delete from PM_RECHARGE where RECHARGE_DATE = @recharge_date
and RECHARGE_PARTNER_ID = @bank_code

go

