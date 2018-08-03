use PMDB

go

set nocount on

declare @company_id       unsigned bigint
declare @document_type_id unsigned bigint
declare @paper_size_id    unsigned bigint
declare @template_id      unsigned bigint

select @company_id = COMPANY_ID from PM_COMPANY where COMPANY_ABBR = 'AMP'

select @document_type_id = DOCUMENT_TYPE_ID from PM_DOCUMENT_TYPE where DOCUMENT_TYPE = 'B'

select @paper_size_id = PAPER_SIZE_ID from PM_PAPER_SIZE where PAPER_SIZE_NAME = 'Z'
if (@@rowcount = 0)
begin

  insert into PM_PAPER_SIZE
  (PAPER_SIZE_NAME, WIDTH, HEIGHT, EFFECTIVE_DATE, ACTIVE_BOO
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  ('Z', 100, 200, '20160616', 'Y'
  , 'init', getdate(), 'init', getdate())

  select @paper_size_id = @@identity

end

select @template_id = TEMPLATE_ID from PM_TEMPLATE where TEMPLATE_NAME = 'Template Unit Test'
if (@@rowcount = 0)
begin

  insert into PM_TEMPLATE
  (TEMPLATE_NAME, TEMPLATE_VERSION, PAPER_SIZE_ID, ACTIVE_BOO
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  ('Template Unit Test', '1.0', @paper_size_id, 'Y'
  , 'unit', getdate(), 'unit', getdate())

  select @template_id = @@identity

end

insert into PM_CREDIT_NOTE
(COMPANY_ID, DOCUMENT_TYPE_ID, TEMPLATE_ID, CN_NO, CN_DATE, MODE
, CN_LOCATION_CODE, CHANNEL_ID, CATEGORY_CODE, BOP_ID, CN_STATUS
, STATUS_DTM, RECEIPT_SENDING, PRINT_ATTACH_BOO, REF_DOC_TYPE
, USER_ID, PREV_NON_VAT_AMT, PREV_NET_VAT_AMT, PREV_VAT_AMT
, PREV_TOTAL_AMT, REFUND_NON_VAT_AMT, REFUND_NET_VAT_AMT
, REFUND_VAT_AMT, REFUND_TOTAL_AMT, NON_VAT_BAL, NET_VAT_BAL
, VAT_BAL, TOTAL_BAL, REFUND_TYPE
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@company_id, @document_type_id, @template_id, 'For Unit Test ROM Package Voice', '20160615', 'BA'
, 1, 1, 1, 3, 'N'
, '20160616', 'NO', 'N', 'RE'
, 'unit', 0, 0, 0
, 0, 0, 0
, 0, 307, 0, 0
, 0, 0, 'CA'
, 'unit', '20160616', 'unit', '20160616')

go

