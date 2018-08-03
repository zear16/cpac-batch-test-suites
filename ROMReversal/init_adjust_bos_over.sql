use PMDB

go

set nocount on

declare @company_id unsigned bigint
declare @document_type_id unsigned bigint
declare @template_id unsigned bigint

select @company_id = COMPANY_ID from PM_COMPANY where COMPANY_ABBR = 'AWN'

select @document_type_id = DOCUMENT_TYPE_ID from PM_DOCUMENT_TYPE where DOCUMENT_TYPE = 'B'

declare @paper_size_id unsigned bigint
declare @paper_size_name varchar(100)

select @paper_size_name = 'Z'

select @paper_size_id = PAPER_SIZE_ID from PM_PAPER_SIZE where PAPER_SIZE_NAME = @paper_size_name
if (@@rowcount = 0)
begin

  insert into PM_PAPER_SIZE
  (PAPER_SIZE_NAME, WIDTH, HEIGHT, EFFECTIVE_DATE, ACTIVE_BOO
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@paper_size_name, 100, 200, getdate(), 'Y'
  , 'unit', getdate(), 'unit', getdate())

  select @paper_size_id = @@identity

end

select @template_id = TEMPLATE_ID from PM_TEMPLATE where TEMPLATE_NAME = 'Template Unit Test'
if (@@rowcount = 0)
begin

  declare @language_id unsigned bigint

  select @language_id = LANGUAGE_ID
  from PM_LANGUAGE
  where LANGUAGE_CODE = 'THA'

  insert into PM_TEMPLATE
  (TEMPLATE_NAME, TEMPLATE_VERSION, PAPER_SIZE_ID, ACTIVE_BOO
  , LANGUAGE_ID
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  ('Template Unit Test', '1.0', @paper_size_id, 'Y'
  , @language_id
  , 'unit', getdate(), 'unit', getdate())

  select @template_id = @@identity

end

select @company_id = COMPANY_ID from PM_COMPANY where COMPANY_ABBR = 'AWN'

insert into PM_ADJUST_BOS
(BATCH_ID, TRANSACTION_ID, MOBILE_NO, PAYMENT_TYPE, MAIN_PRODUCT_ID, MAIN_PRODUCT_SEQUENCE_ID
, MAIN_PROMOTION_STATUS, BRAND, CUSTOMER_SEGMENT, SUBSCRIBER_SEGMENT, IS_TEST_NUMBER_BOO
, COMPANY_ID, NON_MOBILE, USER_TYPE, ACCOUNT_ID, SINGLE_BAL_BOO, SPECIFICATION_ID
, OPERATION_DTM, OPERATION_DATE, REQUEST_ACTION, ASSET_TYPE, ADJUST_VALUE, OLD_VALUE, NEW_VALUE
, CURRENT_STATE, PREVIOUS_STATE, NEW_SUSPEND_FLG, OLD_SUSPEND_FLG, NEW_FRAUD_FLG, OLD_FRAUD_FLG
, NEW_SUSPEND_TYPE, OLD_SUSPEND_TYPE, SYS_PREPAID_BAL_LIMIT, NEGATIVE_BAL, CHANNEL, SOURCE_SYSTEM
, REMARKS, TRANSPARENT_DATA_1, TRANSPARENT_DATA_2
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(0, '00201606160901000010', '0854000673', 'Pre-paid', 1, 1
, 'Active', '3G', 'B', 'Standard', 'N'
, @company_id, 'Mobile', 'Pre-paid', '1', 'Y', 8001
, '20160615', '20160615', 'Add Amount',  0, 16, '0', '16'
, 'Active', 'Active', 'Normal', 'Normal', 'No Fraud', 'No Fraud'
, 'Normal', 'Normal', 0, 0, 1, 'EAI Orders'
, '11111111', 'ROMRVS', NULL
, 'unit', '20160616', 'unit', '20160616')

go

 
