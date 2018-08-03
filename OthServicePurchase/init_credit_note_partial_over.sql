use PMDB

go

set nocount on

declare @company_id       unsigned bigint
declare @document_type_id unsigned bigint
declare @template_id      unsigned bigint
declare @category_code    unsigned bigint
declare @bank_code        unsigned bigint
declare @bop_id           unsigned bigint
declare @sub_bop_id       unsigned bigint
declare @mobile_no        varchar(20)
declare @trans_date       date
declare @cn_id            unsigned bigint
declare @backward      int

select @backward = convert(int,FIELD1_VALUE)
from PM_SYSTEM_ATTRIBUTE_DTL
where ATTRIBUTE_CODE = 'CPAC_PARAM'
and DB_VALUE = 'QUERY_RECHARGE_PERIOD'

select @mobile_no = '0817037536'
, @trans_date = dateadd(mm, -@backward, getdate())

select @company_id = COMPANY_ID from PM_COMPANY where COMPANY_ABBR = 'AWN'

select @document_type_id = DOCUMENT_TYPE_ID from PM_DOCUMENT_TYPE where DOCUMENT_TYPE = 'B'

select @bank_code = BANK_CODE from PM_BANK where BANK_ABBR = 'ROM'

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

  select @language_id = LANGUAGE_ID from PM_LANGUAGE where LANGUAGE_CODE = 'THA'

  insert into PM_TEMPLATE
  (TEMPLATE_NAME, TEMPLATE_VERSION, PAPER_SIZE_ID, ACTIVE_BOO
  , LANGUAGE_ID
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  ('Template Unit Test', '1', @paper_size_id, 'Y'
  , @language_id
  , 'unit', getdate(), 'unit', getdate())

  select @template_id = @@identity

end

select @category_code = CATEGORY_CODE from PM_PAYMENT_CATEGORY where CATEGORY_ABBR = 'MP'

select @bop_id = BOP_ID from PM_BUSINESS_OF_PAYMENT where BOP_CODE = 'I'

select @sub_bop_id = SUB_BOP_ID from PM_SUB_BUSINESS_OF_PAYMENT where SUB_BOP_CODE = 'PU'

print '@company_id=[%1!],@category_code=[%2!],@bank_code=[%3!]', @company_id, @category_code, @bank_code

insert into PM_CREDIT_NOTE
(COMPANY_ID, DOCUMENT_TYPE_ID, TEMPLATE_ID, CN_NO, CN_DATE, MODE
, CN_LOCATION_CODE, CHANNEL_ID, CATEGORY_CODE, BOP_ID, CN_STATUS
, MOBILE_NO, BANK_CODE
, STATUS_DTM, RECEIPT_SENDING, PRINT_ATTACH_BOO, REF_DOC_TYPE
, USER_ID, PREV_NON_VAT_AMT, PREV_NET_VAT_AMT, PREV_VAT_AMT
, PREV_TOTAL_AMT, REFUND_NON_VAT_AMT, REFUND_NET_VAT_AMT
, REFUND_VAT_AMT, REFUND_TOTAL_AMT, NON_VAT_BAL, NET_VAT_BAL
, VAT_BAL, TOTAL_BAL, REFUND_TYPE
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@company_id, @document_type_id, @template_id, 'ForUnitTestDCBPurchase', @trans_date, 'BA'
, 1, 1, @category_code, @bop_id, 'N'
, @mobile_no, @bank_code
, @trans_date, 'NO', 'N', 'RE'
, 'unit', 0, 0, 0
, 0, 0, 0
, 0, 101, 0, 0
, 0, 0, 'CA'
, 'unit', '20160616', 'unit', '20160616')

select @cn_id = @@identity

insert into PM_CREDIT_NOTE_DTL
(CN_ID, CN_DATE, SUB_BOP_ID, DISCOUNT_AMT
, NON_VAT_AMT, NET_VAT_AMT, VAT_RATE, VAT_AMT, TOTAL_AMT
, REFUND_NON_VAT_AMT, REFUND_NET_VAT_AMT, REFUND_VAT_AMT, REFUND_TOTAL_AMT
, NON_VAT_BAL, NET_VAT_BAL, VAT_BAL, TOTAL_BAL
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@cn_id, @trans_date, @sub_bop_id, 0
, 0, 0, 0, 0, 0
, 0, 0, 0, 0
, 0, 0, 0, 0
, 'unit', @trans_date, 'unit', @trans_date)

go

