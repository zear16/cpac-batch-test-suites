use PMDB

go

set nocount on

set proc_output_params off

declare @payment_date     date
declare @mobile_no        varchar(20)
declare @total_bal        decimal(14,2)
declare @company_id       unsigned bigint
declare @document_type_id unsigned bigint
declare @channel_id       unsigned bigint
declare @sub_bop_id       unsigned bigint
declare @template_id      unsigned bigint
declare @package_name     varchar(200)
declare @package_code     unsigned bigint
declare @receipt_id       unsigned bigint
declare @receipt_date     date
declare @receipt_no       char(22)
declare @version_id       unsigned bigint
declare @template_code    varchar(250)
declare @yy               int
declare @mm               int
declare @paper_size_id    unsigned bigint
declare @paper_size_name  varchar(100)
declare @bop_id           unsigned bigint
declare @backward         int

select @mobile_no = '0854000673'
, @total_bal = 3.07
, @payment_date = '20160616'

-- mPAY
select @channel_id = CHANNEL_ID
from PM_PAYMENT_CHANNEL
where CHANNEL_CODE = 'M'

-- Top Up
select @sub_bop_id = SUB_BOP_ID
from PM_SUB_BUSINESS_OF_PAYMENT
where SUB_BOP_CODE = 'PT'

select @backward = PERIOD
from PM_CFG_REVERSAL_PERIOD
where CHANNEL_ID = @channel_id
and SUB_BOP_ID = @sub_bop_id

select @receipt_date = dateadd(dd, -@backward, @payment_date)

select @yy = datepart(yy,@receipt_date)
, @mm = datepart(mm,@receipt_date)

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

select @document_type_id = DOCUMENT_TYPE_ID from PM_DOCUMENT_TYPE where DOCUMENT_TYPE = 'R'

select @bop_id = BOP_ID from PM_BUSINESS_OF_PAYMENT where BOP_CODE = 'P'

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

  insert into PM_TEMPLATE
  (TEMPLATE_NAME, TEMPLATE_VERSION, PAPER_SIZE_ID, ACTIVE_BOO, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  ('Template Unit Test', '1.0', @paper_size_id, 'Y', 'unit', getdate(), 'unit', getdate())

  select @template_id = @@identity

end

select @receipt_no = 'Z-PR-A-' || right(convert(char(4),@yy+543),2) || 
right(replicate('0',2)+convert(varchar(2),@mm),2) || '-0000000016'

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
, @channel_id, 1, @bop_id, 'N', @receipt_date, 'A', 'N'
, 'N', 'unit', 'N', 0, 0, 0, 0, @total_bal
, 0, 0, 0, 0, 0, 0
, 0, @total_bal, 'Y', 'unit', @receipt_date, 'unit', @receipt_date)

select @receipt_id = @@identity

declare @vat_rate decimal(5,2)
declare @net_vat_amt decimal(14,2)
declare @vat_amt decimal(14,2)
declare @ret_msg varchar(250)

exec PM_S_CAL_NET_VAT @mobile_no, @total_bal, @receipt_date, @vat_rate out, @net_vat_amt out, @vat_amt out, @ret_msg out

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

