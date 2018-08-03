use PMDB

go

set nocount on

declare @recharge_id     unsigned bigint
declare @mobile_no       varchar(20)
declare @transaction_dtm char(8)
declare @face_value      decimal(14,2)
declare @batch_no        varchar(10)
declare @start           unsigned bigint
declare @session_id      varchar(64)
declare @batch_id        unsigned bigint
declare @order_id        unsigned bigint
declare @loop            int

select @mobile_no = '0901000009'
, @transaction_dtm = '20160614' -- 20160601 - 2
, @face_value = 307
, @session_id = '16161616161616161616@CC'
, @batch_no = '16001'
, @start = 0
, @loop = 1

delete from PM_CASH_CARD_RECEIPT
where CARD_BATCH_ID = @batch_no
and CARD_SERIAL_NO = @start

while (@loop = 1)
begin

  select @loop = 0

  select @recharge_id = RECHARGE_ID, @batch_id = BATCH_ID
  from PM_RECHARGE
  where RECHARGE_DATE = @transaction_dtm
  and MOBILE_NO = @mobile_no
  and DCC_E_TOPUP_SESSION_ID = @session_id
  if (@@rowcount != 0)
  begin
    select @loop = 1

    select @order_id = ORDER_ID from PM_PREPAID_LOAD_BATCH where BATCH_ID = @batch_id

    delete from PM_RECHARGE
    where RECHARGE_DATE = @transaction_dtm and RECHARGE_ID = @recharge_id

    delete from PM_PREPAID_LOAD_BATCH where BATCH_ID = @batch_id

    delete from PM_JOB_ORDER where ORDER_ID = @order_id

  end

end
