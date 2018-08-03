use PMDB

go

set nocount on

declare @recharge_id unsigned bigint
declare @mobile_no varchar(20)
declare @transaction_dtm char(8)
declare @face_value decimal(14,2)
declare @session_id varchar(64)
declare @recharge_channel unsigned bigint
declare @order_id unsigned bigint
declare @batch_id unsigned bigint

select @mobile_no = '0901000009'
, @transaction_dtm = '20160616'
, @face_value = 3.07 
, @session_id = '16161616161616161616@MPAY'

select @recharge_channel = SERVICE_ID
from PM_RECHARGE_SERVICE R
--inner join PM_CFG_RECHARGE_SERVICE C on (R.SERVICE_ROW_ID = C.SERVICE_ROW_ID)
where R.BANK_CODE = 500

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

select @recharge_id = RECHARGE_ID from PM_RECHARGE
where RECHARGE_DATE = @transaction_dtm
and MOBILE_NO = @mobile_no
and DCC_E_TOPUP_SESSION_ID = @session_id
if (@@rowcount = 0)
begin
  
  insert into PM_RECHARGE
  (BATCH_ID, TRANSACTION_ID, MAIN_PRODUCT_ID, BRAND, IS_TEST_NUMBER_BOO
  , RECHARGE_CHANNEL, RECHARGE_PARTNER_ID, RECEIPT_NO
  , COMPANY_ID, USER_TYPE, RECHARGE_DATE, TRANSACTION_DTM, DCC_E_TOPUP_SESSION_ID
  , SPECIFICATION_ID, CUSTOMER_ID, ACCOUNT_ID, SINGLE_BAL_BOO
  , CHANNEL, MOBILE_NO, RECHARGE_AMT, OLD_USER_STATE, CURRENT_USER_STATE
  , NEW_ACTIVE_BEGIN_DTM, NEW_ACTIVE_STOP_DTM, NEW_SUSPEND_STOP_DTM
  , NEW_DISABLE_STOP_DTM, CONVERT_TO_RECEIPT_BOO
  , BILLING_SYSTEM
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@batch_id, '16161616', 1, '3G', 'Y'
  , @recharge_channel, 500, 'UNIT-TEST'
  , 1, 'Pre-paid', @transaction_dtm, @transaction_dtm, @session_id
  , 10101, '1', '1', 'Y'
  , 14, @mobile_no, @face_value, 'Active', 'Active'
  , @transaction_dtm, @transaction_dtm, @transaction_dtm
  , @transaction_dtm, 'Y'
  , 'BOS'
  , 'unit', getdate(), 'unit', getdate())

end

go

 
