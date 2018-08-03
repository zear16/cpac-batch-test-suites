use PMDB

go

set nocount on

declare @recharge_id unsigned bigint
declare @mobile_no varchar(20)
declare @transaction_dtm char(8)
declare @face_value decimal(14,2)
declare @session_id varchar(64)
declare @batch_id unsigned bigint
declare @order_id unsigned bigint
declare @loop int

select @mobile_no = '0810083859'
, @transaction_dtm = '20160616'
, @face_value = 778200
, @session_id = 'UNIT_TEST_PARTNER_TOPUP'
, @loop = 1

while (@loop = 1)
begin

  select @loop = 0

  select @recharge_id = RECHARGE_ID, @batch_id = BATCH_ID 
  from PM_RECHARGE
  where TRANSACTION_DTM = @transaction_dtm
  and MOBILE_NO = @mobile_no
  and DCC_E_TOPUP_SESSION_ID = @session_id
  if (@@rowcount != 0)
  begin
    select @loop = 1

    select @order_id = ORDER_ID from PM_PREPAID_LOAD_BATCH where BATCH_ID = @batch_id

    delete from PM_RECHARGE
    where TRANSACTION_DTM = @transaction_dtm and RECHARGE_ID = @recharge_id

    delete from PM_PREPAID_LOAD_BATCH where BATCH_ID = @batch_id

    delete from PM_JOB_ORDER where ORDER_ID = @order_id

  end

end

go
