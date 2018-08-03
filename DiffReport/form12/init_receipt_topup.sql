use PMDB

go

declare cur cursor for
  select CS.BA_NO, CS.MOBILE_NO, convert(decimal(5,2), left(CS.CUS_VAT_RATE,1)), C.COMPANY_ID, C.COMPANY_CODE
  from PM_V_CUST_PROFILE CS
  inner join PM_COMPANY C on (CS.INVOICING_COMPANY = C.COMPANY_ABBR)
  where CS.MOBILE_NO in ('0854050028', '0810076836', '0854065167', '0854074673', '0810027579', '0819088499')
  and CS.CHARGE_TYPE = 'Pre-paid'
go


declare @receipt_no           varchar(50)
declare @excess_no            varchar(50)
declare @ret_msg              varchar(250)
declare @ret_code             int
declare @company_id           unsigned bigint
declare @company_code         varchar(2)
declare @receipt_id           unsigned bigint
declare @receipt_dtl_id       unsigned bigint
declare @receipt_date         date
declare @document_type        char(1)
declare @document_type_id     unsigned bigint
declare @location_code        unsigned bigint
declare @channel_code         char(2)
declare @channel_id           unsigned bigint
declare @category_abbr        char(5)
declare @category_code        unsigned bigint
declare @bop_id               unsigned bigint
declare @bop_code             varchar(2)
declare @sub_bop_id           unsigned bigint
declare @non_vat_amt          decimal(14,2)
declare @net_vat_amt          decimal(14,2)
declare @vat_amt              decimal(14,2)
declare @total_amt            decimal(14,2)
declare @vat_rate             decimal(5,2)
declare @bank_code            unsigned bigint
declare @ba_no                varchar(50)
declare @mobile_no            varchar(20)                

select @location_code = 1020
     , @document_type = 'B'
     , @channel_code = 'Q'
     , @category_abbr = 'PP'
     , @total_amt = 40
     , @non_vat_amt = 0
     , @bank_code = 999

select @receipt_date = O.DATA_DATE_FR
from PM_JOB_ORDER O
where O.TEMPLATE_CODE = 'RECONCILE_CONVERT_POST_TO_PRE'
and O.RUN_DATE = convert(date, getdate())

select @document_type_id = DOCUMENT_TYPE_ID from PM_DOCUMENT_TYPE where DOCUMENT_TYPE = @document_type

select @channel_id = CHANNEL_ID, @category_code = CATEGORY_CODE
from PM_PAYMENT_CATEGORY
where CATEGORY_ABBR = @category_abbr

select @bop_id = BOP_ID, @sub_bop_id = SUB_BOP_ID from PM_SUB_BUSINESS_OF_PAYMENT where SUB_BOP_CODE = 'PT'

select @bop_code = BOP_CODE from PM_BUSINESS_OF_PAYMENT where BOP_ID = @bop_id

-- clean up

delete PM_RECEIPT_DTL
from PM_RECEIPT_DTL RD 
inner join PM_RECEIPT R on (RD.RECEIPT_ID = R.RECEIPT_ID and RD.RECEIPT_DATE = R.RECEIPT_DATE)
where R.MOBILE_NO in ('0854050028', '0810076836', '0854065167', '0854074673', '0810027579', '0819088499')
and R.RECEIPT_DATE = @receipt_date

delete PM_RECEIPT
from PM_RECEIPT R 
where R.MOBILE_NO in ('0854050028', '0810076836', '0854065167', '0854074673', '0810027579', '0819088499')
and R.RECEIPT_DATE = @receipt_date

----


open cur

fetch next  cur into @ba_no, @mobile_no, @vat_rate, @company_id, @company_code

while (@@sqlstatus = 0)
begin

  execute @ret_code = PM_S_GEN_DOC_NO 'CLMD', @company_code, @bop_code
     , @document_type, @channel_code, @location_code, null, '6001', 1
     , @receipt_no out, @ret_msg out

  select @total_amt = @total_amt + 10

  execute @ret_code = dbo.PM_S_CAL_NET_VAT @mobile_no, @total_amt, @receipt_date
                               , @vat_rate out, @net_vat_amt out, @vat_amt out, @ret_msg out


  insert into PM_RECEIPT(
      RECEIPT_DATE, COMPANY_ID, DOCUMENT_TYPE_ID, TEMPLATE_ID
    , RECEIPT_NO, MODE, CHANNEL_ID, CATEGORY_CODE, BOP_ID, BANK_CODE
    , RECEIPT_STATUS, STATUS_DTM, MODEL, RECEIPT_SENDING, FUTURE_RECEIPT_BOO
    , USER_ID, VAT_CAL_BOO, ALLOW_CANCEL_BOO
    , NON_VAT_AMT, NET_VAT_AMT, VAT_AMT, VAT_RATE, TOTAL_AMT
    , REFUND_NON_VAT_AMT, REFUND_NET_VAT_AMT, REFUND_VAT_AMT, REFUND_TOTAL_AMT
    , NON_VAT_BAL, NET_VAT_BAL, VAT_BAL, TOTAL_BAL
    , RECEIPT_LOCATION_CODE, MOBILE_NO
    , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD
  )
  values(
    @receipt_date, @company_id, @document_type_id, 1
    , @receipt_no, 'BA', @channel_id, @category_code, @bop_id, @bank_code
    , 'N', getdate(), 'OR', 'NO', 'N'
    , 'CLMD', 'Y', 'Y'
    , @non_vat_amt, @net_vat_amt, @vat_amt, @vat_rate, @total_amt
    , 0, 0, 0, 0
    , @non_vat_amt, @net_vat_amt, @vat_amt, @total_amt
    , @location_code, @mobile_no
    , 'CLMD', getdate(), 'SUYADA', getdate()
  )

  select @receipt_id = @@identity

  insert into PM_RECEIPT_DTL(
    RECEIPT_ID, RECEIPT_DATE, SUB_BOP_ID, BA_NO, MOBILE_NO
    , ITEM_NO, NEGO_BOO
    , DISCOUNT_AMT, NON_VAT_AMT, NET_VAT_AMT, VAT_RATE, VAT_AMT, TOTAL_AMT
    , REFUND_NON_VAT_AMT, REFUND_NET_VAT_AMT, REFUND_VAT_AMT, REFUND_TOTAL_AMT
    , NON_VAT_BAL, NET_VAT_BAL, VAT_BAL, TOTAL_BAL
    , ADJ_VAT_AMT
    , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD
  )
  values(
    @receipt_id, @receipt_date, @sub_bop_id, @ba_no, @mobile_no
    , 1, 'N'
    , 0, @non_vat_amt, @net_vat_amt, @vat_amt, @vat_rate, @total_amt
    , 0, 0, 0, 0
    , @non_vat_amt, @net_vat_amt, @vat_amt, @total_amt
    , 0
    , 'CLMD', getdate(), 'SUYADA', getdate()
  )

  fetch next  cur into @ba_no, @mobile_no, @vat_rate, @company_id, @company_code
end

go
