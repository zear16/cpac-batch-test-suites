use PMDB

go

set nocount on

declare @recharge_id      unsigned bigint
declare @mobile_no        varchar(20)
declare @transaction_dtm  char(8)
declare @face_value       decimal(14,2)
declare @session_id       varchar(24)
declare @recharge_channel unsigned bigint
declare @order_id         unsigned bigint
declare @batch_id         unsigned bigint
declare @receipt_no       char(22)
declare @receipt_date     char(8)
declare @receipt_status   char(1)
declare @company_id       unsigned bigint
declare @location_code    unsigned bigint
declare @method_code      unsigned bigint
declare @category_code    unsigned bigint
declare @document_type_id unsigned bigint
declare @bank_code        unsigned bigint
declare @backward         int
declare @yy               int
declare @mm               int

select @mobile_no = '0854000673'
, @transaction_dtm = '20160616'
, @face_value = 13.07
, @location_code = 1020
, @receipt_status = 'N'
, @bank_code = 501

select @backward = convert(int,FIELD1_VALUE)
from PM_SYSTEM_ATTRIBUTE_DTL
where ATTRIBUTE_CODE = 'CPAC_PARAM'
and DB_VALUE = 'QUERY_RECHARGE_PERIOD'

select @yy = datepart(yy,dateadd(mm,-@backward,getdate()))
, @mm = datepart(mm,dateadd(mm,-@backward,getdate()))

select @receipt_date = convert(char(4),@yy) ||
right(replicate('0',2)+convert(varchar(2),@mm),2) || '01'

select @session_id = right(@receipt_date,6) || '14104723456789@ROM'

select @company_id = COMPANY_ID from PM_COMPANY where COMPANY_CODE = 'Z'
if (@@rowcount = 0)
begin

  insert into PM_COMPANY
  (COMPANY_CODE, COMPANY_ABBR, COMPANY_NAME, COMPANY_NAME_TH, ACTIVE_BOO
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  ('Z', 'ZZZ', 'Z Company', 'บริษัท Z', 'Y'
  , 'test', getdate(), 'test', getdate())

end

select @document_type_id = DOCUMENT_TYPE_ID from PM_DOCUMENT_TYPE where DOCUMENT_TYPE = 'B'

select @method_code = METHOD_CODE from PM_PAYMENT_METHOD where METHOD_ABBR = 'CA'

select @category_code = CATEGORY_CODE from PM_PAYMENT_CATEGORY where CATEGORY_ABBR = 'TB'

select @recharge_channel = SERVICE_ID
from PM_RECHARGE_SERVICE R
where R.BANK_CODE = @bank_code
and R.RECHARGE_BOO = 'Y'

select @receipt_no = 'Z-PB-A-' || right(convert(char(4),@yy+543),2) ||
right(replicate('0',2)+convert(varchar(2),@mm),2) || '-0000000016'

select @order_id = ORDER_ID from PM_JOB_ORDER
where TEMPLATE_CODE = @session_id
and RUN_DATE = @transaction_dtm
if (@@rowcount = 0)
begin

  insert into PM_JOB_ORDER
  (ORDER_TYPE, ORDER_MODE, RUN_DATE, DATA_DATE_FR, DATA_DATE_TO, ORDER_STATUS)
  values
  ('I', 'A', @receipt_date, @receipt_date, dateadd(dd, 1, @receipt_date), 'S')

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
where RECHARGE_DATE = @receipt_date
and MOBILE_NO = @mobile_no
and DCC_E_TOPUP_SESSION_ID = @session_id
if (@@rowcount = 0)
begin
  
  insert into PM_RECHARGE
  (BATCH_ID, TRANSACTION_ID, MAIN_PRODUCT_ID, BRAND, IS_TEST_NUMBER_BOO
  , RECHARGE_CHANNEL, CATEGORY_CODE, METHOD_CODE, RECEIPT_TEMPLATE_ID, DOCUMENT_TYPE_ID
  , RECEIPT_AMT, RECHARGE_PARTNER_ID
  , COMPANY_ID, USER_TYPE, RECHARGE_DATE, TRANSACTION_DTM, DCC_E_TOPUP_SESSION_ID
  , CARD_BATCH_ID, CARD_SERIAL_NO
  , RECEIPT_NO, RECEIPT_STATUS, RECEIPT_DATE, RECEIPT_LOCATION_CODE
  , SPECIFICATION_ID, CUSTOMER_ID, ACCOUNT_ID, SINGLE_BAL_BOO
  , CHANNEL, MOBILE_NO, RECHARGE_AMT, OLD_USER_STATE, CURRENT_USER_STATE
  , NEW_ACTIVE_BEGIN_DTM, NEW_ACTIVE_STOP_DTM, NEW_SUSPEND_STOP_DTM
  , NEW_DISABLE_STOP_DTM, CONVERT_TO_RECEIPT_BOO
  , BILLING_SYSTEM
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@batch_id, '16161616', 1, '3G', 'Y'
  , @recharge_channel, @category_code, @method_code, 100, @document_type_id
  , @face_value, @bank_code
  , 1, 'Pre-paid', @receipt_date, @receipt_date, @session_id
  , left(@session_id,10), right(left(@session_id,20),10)
  , @receipt_no, @receipt_status, @receipt_date, @location_code
  , 10101, '1', '1', 'Y'
  , 14, @mobile_no, @face_value, 'Active', 'Active'
  , @receipt_date, @receipt_date, @receipt_date
  , @receipt_date, 'N'
  , 'BOS'
  , 'unit', getdate(), 'unit', getdate())

end

go

 
