use PMDB

go

set nocount on

declare @type_id          varchar(4)
declare @scratch_type     char(1)
declare @sc_type_id       unsigned bigint
declare @sc_stock_id      unsigned bigint
declare @batch_no         varchar(10)
declare @start            unsigned bigint
declare @qty              unsigned int
declare @value            decimal(14,2)
declare @recharge_id      unsigned bigint
declare @mobile_no        varchar(20)
declare @transaction_dtm  char(8)
declare @face_value       decimal(14,2)
declare @session_id       varchar(64)
declare @recharge_channel unsigned bigint
declare @order_id         unsigned bigint
declare @batch_id         unsigned bigint

select @type_id = 'UNIT'
, @scratch_type = 'S'
, @batch_no = '16001'
, @start = 0
, @qty = 100
, @value = 200
, @mobile_no = '0901000009'
, @transaction_dtm = '20160614' -- 20160616 - 2
, @face_value = 200
, @session_id = '16161616161616161616@CC'
, @recharge_channel = 0

select @sc_type_id = SC_TYPE_ID
from PM_SCRATCH_TYPE
where TYPE_ID = @type_id
and SCRATCH_TYPE = @scratch_type
if (@sc_type_id = null)
begin

  insert into PM_SCRATCH_TYPE
  (TYPE_ID, TYPE_DESCRIPTION, SCRATCH_TYPE
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@type_id, 'UNIT TEST', @scratch_type
  , 'init', getdate(), 'init', getdate()) 

end

select @sc_stock_id = SC_STOCK_ID
from PM_SCRATCH_STOCK
where BATCH_NO = @batch_no
and START_SERIAL_NO = 0
if (@@rowcount = 0)
begin

  insert into PM_SCRATCH_STOCK
  (BATCH_NO, START_SERIAL_NO, BATCH_QTY, FACE_VALUE
  , TYPE_ID, SCRATCH_TYPE, COMMERCE_BOO
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@batch_no, @start, @qty, @value
  , @type_id, @scratch_type, 'Y'
  , 'unit', getdate(), 'unit', getdate())

end
else
begin

  update PM_SCRATCH_STOCK set START_SERIAL_NO = @start
  , BATCH_QTY = @qty
  , FACE_VALUE = @value
  , TYPE_ID = @type_id
  , SCRATCH_TYPE = @scratch_type
  , COMMERCE_BOO = 'Y'
  where SC_STOCK_ID = @sc_stock_id

end

select @order_id = ORDER_ID from PM_JOB_ORDER
where TEMPLATE_CODE = @session_id
and RUN_DATE = @transaction_dtm
if (@@rowcount = 0)
begin

  insert into PM_JOB_ORDER
  (ORDER_TYPE, ORDER_MODE, RUN_DATE, DATA_DATE_FR, DATA_DATE_TO, ORDER_STATUS)
  values
  ('I', 'A', @transaction_dtm, @transaction_dtm, dateadd(dd, 1, @transaction_dtm), 'S')

  select @order_id = @@identity

end

select @batch_id = BATCH_ID from PM_PREPAID_LOAD_BATCH where ORDER_ID = @order_id
if (@@rowcount = 0)
begin

  insert into PM_PREPAID_LOAD_BATCH
  (ORDER_ID, PROCESS_TYPE, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@order_id, 'I', 'unit', getdate(), 'unit', getdate())

  select @batch_id = @@identity

end

delete from PM_RECHARGE
where RECHARGE_DATE = @transaction_dtm
and MOBILE_NO = @mobile_no
and DCC_E_TOPUP_SESSION_ID = @session_id

insert into PM_RECHARGE
(BATCH_ID, TRANSACTION_ID, MAIN_PRODUCT_ID, BRAND, IS_TEST_NUMBER_BOO
, RECHARGE_CHANNEL, RECHARGE_PARTNER_ID
, COMPANY_ID, USER_TYPE, RECHARGE_DATE, TRANSACTION_DTM, DCC_E_TOPUP_SESSION_ID
, SPECIFICATION_ID, CUSTOMER_ID, ACCOUNT_ID, SINGLE_BAL_BOO
, CHANNEL, MOBILE_NO, RECHARGE_AMT, OLD_USER_STATE, CURRENT_USER_STATE
, NEW_ACTIVE_BEGIN_DTM, NEW_ACTIVE_STOP_DTM, NEW_SUSPEND_STOP_DTM
, NEW_DISABLE_STOP_DTM, CONVERT_TO_RECEIPT_BOO
, CARD_BATCH_ID, CARD_SERIAL_NO
, BILLING_SYSTEM
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@batch_id, '16161616', 1, '3G', 'Y'
, @recharge_channel, 500
, 1, 'Pre-paid', @transaction_dtm, @transaction_dtm, @session_id
, 10101, '1', '1', 'Y'
, 14, @mobile_no, @face_value, 'Active', 'Active'
, @transaction_dtm, @transaction_dtm, @transaction_dtm
, @transaction_dtm, 'Y'
, @batch_no, convert(varchar(32),@start)
, 'BOS'
, 'unit', getdate(), 'unit', getdate())

delete from PM_CASH_CARD_RECEIPT
where CARD_BATCH_ID = @batch_no
and CARD_SERIAL_NO = convert(varchar(32),@start)

insert into PM_CASH_CARD_RECEIPT
(MOBILE_NO, SERVICE_ID, RECHARGE_DTM, CARD_BATCH_ID, CARD_SERIAL_NO
, START_SERIAL_NO, RECEIPT_NO, BILLING_SYSTEM
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@mobile_no, 0, @transaction_dtm, @batch_no, convert(varchar(32),@start)
, @start, 'Z-PB-D-5906-0000000016', 'BOS'
, 'unit', getdate(), 'unit', getdate()) 

go


