use PMDB

go

set nocount on

declare @company_id unsigned bigint
declare @document_type_id unsigned bigint
declare @template_id unsigned bigint
declare @package_name varchar(200)
declare @package_code unsigned bigint
declare @receipt_id unsigned bigint
declare @run_date char(8)
declare @version_id unsigned bigint
declare @job_id unsigned bigint
declare @job_chain varchar(250)
declare @order_id unsigned bigint

select @run_date = '20160616'

select @job_id = JOB_ID, @job_chain = JOB_CHAIN from PM_JOB_SCHEDULER_MAPPING where TEMPLATE_CODE = "PE_Package_BOS"

select @company_id = COMPANY_ID from PM_COMPANY where COMPANY_ABBR = 'AMP'

select @document_type_id = DOCUMENT_TYPE_ID from PM_DOCUMENT_TYPE where DOCUMENT_TYPE = 'B'

select @template_id = TEMPLATE_ID from PM_TEMPLATE where TEMPLATE_NAME = 'Template Unit Test'
if (@@rowcount = 0)
begin

  insert into PM_TEMPLATE
  (TEMPLATE_NAME, ACTIVE_BOO, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  ('Template Unit Test', 'Y', 'unit', getdate(), 'unit', getdate())

  select @template_id = @@identity

end

insert into PM_RECEIPT
(COMPANY_ID, DOCUMENT_TYPE_ID, TEMPLATE_ID, RECEIPT_NO, RECEIPT_DATE, MODE, RECEIPT_LOCATION_CODE
, CHANNEL_ID, CATEGORY_CODE, BOP_ID, RECEIPT_STATUS, STATUS_DTM, MODEL, RECEIPT_SENDING
, FUTURE_RECEIPT_BOO, USER_ID, VAT_CAL_BOO, NON_VAT_AMT, NET_VAT_AMT, VAT_AMT, VAT_RATE, TOTAL_AMT
, REFUND_NON_VAT_AMT, REFUND_NET_VAT_AMT, REFUND_VAT_AMT, REFUND_TOTAL_AMT, NON_VAT_BAL, NET_VAT_BAL
, VAT_BAL, TOTAL_BAL, ALLOW_CANCEL_BOO, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@company_id, @document_type_id, @template_id, 'Unit Test ROM Package Data', '20160616', 'A', 1
, 1, 1, 1, 'N', '20160616', 'A', 'N'
, 'N', 'unit', 'N', 0, 0, 0, 0, 0
, 0, 0, 0, 0, 0, 0
, 0, 0, 'Y', 'unit', '20160616', 'unit', '20160616')

select @receipt_id = @@identity

select @package_name = 'Unit Test Normal Package Data'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name
if (@@rowcount = 0)
begin

  insert into PM_PACKAGE
  (PACKAGE_CODE, PACKAGE_NAME, PACKAGE_TYPE, PACKAGE_FEE, TOPUP_BOO, ACTIVE_BOO, EFFECTIVE_DATE
   , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (161617, @package_name, 'D', 100, 'Y', 'Y', @run_date
   , 'unit', getdate(), 'unit', getdate())

  select @package_code = 161617

end

select @version_id = max(V.VERSION_ID) from
PM_FILE_CONFIG_VERSION V
inner join PM_FILE_CONFIG C on (C.FILE_CONFIG_ID = V.FILE_CONFIG_ID)
where C.TEMPLATE_CODE = "PE_Package_BOS"

insert into PM_JOB_ORDER
(ORDER_TYPE, JOB_ID, TEMPLATE_CODE, ORDER_MODE, RUN_DATE, DATA_DATE_FR, DATA_DATE_TO,
VERSION_ID, FILE_NAME, ORIGINAL_FILE_NAME, FILE_PATH, ZIP_NAME, JOB_CHAIN, ORDER_STATUS)
values
("I", @job_id, "PE_Package_BOS", "A", @run_date, @run_date, @run_date,
@version_id, "Unit Test ROM Package Data", "Unit Test ROM Package Data", "/opt/ais/cpac/batchprepaid/package", "", @job_chain, "W")

select @order_id = @@identity

declare @batch_id unsigned bigint

insert into PM_PREPAID_LOAD_BATCH
(ORDER_ID, PROCESS_TYPE, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@order_id, 'I', 'unit', @run_date, 'unit', @run_date)

select @batch_id = @@identity

insert into PM_PACKAGE_BOS
(BATCH_ID, MOBILE_NO, MAIN_PRODUCT_ID, MAIN_PRODUCT_SEQ_ID, BRAND, CUSTOMER_SEGMENT
, SUBSCRIBER_SEGMENT, IS_TEST_NUMBER_BOO, COMPANY_ID, NON_MOBILE, USER_TYPE, ACCOUNT_ID
, SINGLE_BAL_BOO, PRODUCT_ID, PRODUCT_SEQUENCE_ID, PRODUCT_NAME, PRODUCT_LEVEL, IS_MAIN_BOO
, OPERATION_TYPE, CHANNEL, OPERATION_DTM, USER_ID, PRODUCT_PRICE_VALUE, INCLUDE_TAX_BOO
, RECEIPT_ID, RECEIPT_DATE, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@batch_id, '0901000009', 1, 1, '3G', 'B'
, 'Standard', 'N', @company_id, 'Mobile', 'Pre-paid', 1
, 'Y', @package_code, 100000035583, @package_name, 0, 'Y'
, 0, 14, '20160616', 'unit', 100, 'N' 
, @receipt_id, '20160616', 'unit', '20160616', 'unit', '20160616')

go

 
