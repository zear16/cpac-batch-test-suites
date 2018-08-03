use PMDB

go

set nocount on

set proc_output_params off

declare @mobile_no        varchar(20)
declare @total_bal        decimal(14,2)
declare @company_id       unsigned bigint
declare @document_type_id unsigned bigint
declare @template_id      unsigned bigint
declare @bop_id           unsigned bigint
declare @package_name     varchar(200)
declare @package_code     unsigned bigint
declare @receipt_id       unsigned bigint
declare @receipt_date     char(8)
declare @receipt_no       char(22)
declare @version_id       unsigned bigint
declare @template_code    varchar(250)
declare @backward         int
declare @yy               int
declare @mm               int

select @mobile_no = '0819017657', @total_bal = 60

select @backward = convert(int,FIELD1_VALUE)
from PM_SYSTEM_ATTRIBUTE_DTL
where ATTRIBUTE_CODE = 'CPAC_PARAM'
and DB_VALUE = 'QUERY_RECHARGE_PERIOD'

select @yy = datepart(yy,dateadd(mm,-@backward,getdate()))
, @mm = datepart(mm,dateadd(mm,-@backward,getdate()))

select @receipt_date = convert(char(4),@yy) || 
right(replicate('0',2)+convert(varchar(2),@mm),2) || '01'

select @company_id = COMPANY_ID from PM_COMPANY where COMPANY_CODE = 'W'

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

select @bop_id = BOP_ID from PM_BUSINESS_OF_PAYMENT where BOP_CODE = 'P'

select @receipt_no = 'W-PB-A-' || right(convert(char(4),@yy+543),2) || 
right(replicate('0',2)+convert(varchar(2),@mm),2) || '-0000000017'

insert into PM_RECEIPT
(COMPANY_ID, DOCUMENT_TYPE_ID, TEMPLATE_ID, RECEIPT_NO, RECEIPT_DATE, MODE, RECEIPT_LOCATION_CODE
, MOBILE_NO
, CHANNEL_ID, CATEGORY_CODE, BOP_ID, RECEIPT_STATUS, STATUS_DTM, MODEL, RECEIPT_SENDING
, FUTURE_RECEIPT_BOO, USER_ID, VAT_CAL_BOO, NON_VAT_AMT, NET_VAT_AMT, VAT_AMT, VAT_RATE, TOTAL_AMT
, REFUND_NON_VAT_AMT, REFUND_NET_VAT_AMT, REFUND_VAT_AMT, REFUND_TOTAL_AMT, NON_VAT_BAL, NET_VAT_BAL
, VAT_BAL, TOTAL_BAL, ALLOW_CANCEL_BOO, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@company_id, @document_type_id, @template_id, @receipt_no, @receipt_date, 'A', 1
, @mobile_no
, 1, 1, @bop_id, 'N', @receipt_date, 'A', 'N'
, 'N', 'unit', 'N', 0, 0, 0, 0, @total_bal
, 0, 0, 0, 0, 0, 0
, 0, @total_bal, 'Y', 'unit', @receipt_date, 'unit', @receipt_date)

select @receipt_id = @@identity

declare @sub_bop_id unsigned bigint
declare @vat_rate decimal(5,2)
declare @net_vat_amt decimal(14,2)
declare @vat_amt decimal(14,2)
declare @ret_msg varchar(250)

select @sub_bop_id = SUB_BOP_ID
from PM_SUB_BUSINESS_OF_PAYMENT
where BOP_ID = 4

declare @ret_status int
exec @ret_status = PM_S_CAL_NET_VAT @mobile_no, @total_bal, @receipt_date
  , @vat_rate out, @net_vat_amt out, @vat_amt out, @ret_msg out

insert into PM_RECEIPT_DTL
(RECEIPT_DATE, RECEIPT_ID, SUB_BOP_ID, ITEM_NO, NEGO_BOO
, MOBILE_NO
, DISCOUNT_AMT, NON_VAT_AMT, NET_VAT_AMT, VAT_RATE, VAT_AMT, TOTAL_AMT
, REFUND_NON_VAT_AMT, REFUND_NET_VAT_AMT, REFUND_VAT_AMT, REFUND_TOTAL_AMT
, NON_VAT_BAL, NET_VAT_BAL, VAT_BAL, TOTAL_BAL, ADJ_VAT_AMT
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
select @receipt_date, @receipt_id, @sub_bop_id, 1, 'N'
, @mobile_no
, 0, 0, @net_vat_amt, @vat_rate, @vat_amt, @total_bal
, 0, @net_vat_amt, @vat_amt, @total_bal
, 0, @net_vat_amt, @vat_amt, @total_bal, @vat_amt
, 'unit', getdate(), 'unit', getdate()

go

