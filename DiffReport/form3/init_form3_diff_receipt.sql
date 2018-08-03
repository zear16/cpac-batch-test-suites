use PMDB

go

declare cur cursor for
  select CS.BA_NO, CS.MOBILE_NO, C.COMPANY_ID, C.COMPANY_CODE, CS.BILLING_SYSTEM, convert(decimal(5,2), left(CS.CUS_VAT_RATE,1))
  from PM_V_CUST_PROFILE CS
  inner join PM_COMPANY C on (CS.INVOICING_COMPANY = C.COMPANY_ABBR)
  where CS.CHARGE_TYPE = 'Pre-paid'
  and CS.MOBILE_STATUS = 'Active'
  and CS.MOBILE_NO in ('0817057150', '0854022988', '0954001664', '0817097482', '0901018129', '0819061634', '0901013476', '0800035619', '0854065306')
  order by CS.BILLING_SYSTEM
go

declare @batch_id         unsigned bigint
declare @company_id       unsigned bigint
declare @company_code     varchar(2)
declare @mobile_no        varchar(20)
declare @ba_no            varchar(30)
declare @operation_date   date
declare @total_amt        decimal(14,2)
declare @billing_system   varchar(5)
declare @bank_code        unsigned bigint

declare @cur_system       varchar(5)

declare @receipt_date     date
declare @location_code    unsigned bigint
declare @document_type    varchar(2)
declare @channel_code     varchar(2)
declare @category_abbr    varchar(2)
declare @non_vat_amt      decimal(14,2)
declare @net_vat_amt      decimal(14,2)
declare @vat_amt          decimal(14,2)
declare @vat_rate         decimal(5,2)
declare @channel_id       unsigned bigint
declare @category_code    unsigned bigint
declare @document_type_id unsigned bigint
declare @bop_id           unsigned bigint
declare @bop_code         varchar(2)
declare @sub_bop_id       unsigned bigint
declare @receipt_no       varchar(30)
declare @receipt_id       unsigned bigint

declare @ret_code         int
declare @ret_msg          varchar(250)

select @operation_date = '20170117'
     , @cur_system = null
     , @total_amt = 50

select @receipt_date = @operation_date
     , @location_code = 1020
     , @document_type = 'B'
     , @channel_code = 'P'
     , @category_abbr = 'MP'
     , @non_vat_amt = 0
     , @bank_code = 800

select @document_type_id = DOCUMENT_TYPE_ID from PM_DOCUMENT_TYPE where DOCUMENT_TYPE = @document_type

select @channel_id = CHANNEL_ID, @category_code = CATEGORY_CODE
from PM_PAYMENT_CATEGORY
where CATEGORY_ABBR = @category_abbr

select @bop_id = BOP_ID, @sub_bop_id = SUB_BOP_ID from PM_SUB_BUSINESS_OF_PAYMENT where SUB_BOP_CODE = 'RE'

select @bop_code = BOP_CODE from PM_BUSINESS_OF_PAYMENT where BOP_ID = @bop_id



-- cleanup
delete PM_RECEIPT_DTL
from PM_RECEIPT_DTL RD
inner join PM_RECEIPT R on (RD.RECEIPT_ID = R.RECEIPT_ID 
                        and RD.RECEIPT_DATE = R.RECEIPT_DATE)
where R.MOBILE_NO in ('0817057150', '0854022988', '0954001664', '0817097482', '0901018129', '0819061634', '0901013476', '0800035619', '0854065306')
and R.RECEIPT_DATE = @receipt_date
and R.CATEGORY_CODE = @category_code

print 'delete PM_RECEIPT_DTL %1! records', @@rowcount

delete PM_RECEIPT
from PM_RECEIPT R
where R.MOBILE_NO in ('0817057150', '0854022988', '0954001664', '0817097482', '0901018129', '0819061634', '0901013476', '0800035619', '0854065306')
and R.RECEIPT_DATE = @receipt_date
and R.CATEGORY_CODE = @category_code

print 'delete PM_RECEIPT %1! records', @@rowcount
-------------

open cur

fetch next cur into @ba_no,@mobile_no, @company_id, @company_code, @billing_system, @vat_rate

while (@@sqlstatus = 0)
begin


-- PM_RECEIPT

  execute @ret_code = PM_S_GEN_DOC_NO 'CLMD', @company_code, @bop_code
     , @document_type, @channel_code, @location_code, null, '6001', 1
     , @receipt_no out, @ret_msg out

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

  print 'insert PM_RECEIPT %1! record', @@rowcount

  insert into PM_RECEIPT_DTL(
    RECEIPT_ID, RECEIPT_DATE, SUB_BOP_ID, BA_NO, MOBILE_NO
    , ITEM_NO, NEGO_BOO
    , DISCOUNT_AMT, NON_VAT_AMT, NET_VAT_AMT, VAT_RATE, VAT_AMT, TOTAL_AMT
    , REFUND_NON_VAT_AMT, REFUND_NET_VAT_AMT, REFUND_VAT_AMT, REFUND_TOTAL_AMT
    , NON_VAT_BAL, NET_VAT_BAL, VAT_BAL, TOTAL_BAL
    , ADJ_VAT_AMT, SOURCE_SYSTEM
    , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD
  )
  values(
    @receipt_id, @receipt_date, @sub_bop_id, @ba_no, @mobile_no
    , 1, 'N'
    , 0, @non_vat_amt, @net_vat_amt, @vat_amt, @vat_rate, @total_amt
    , 0, 0, 0, 0
    , @non_vat_amt, @net_vat_amt, @vat_amt, @total_amt
    , 0, @billing_system
    , 'CLMD', getdate(), 'SUYADA', getdate()
  )

  print 'insert PM_RECEIPT_DTL %1! record', @@rowcount
--------
  fetch next cur into @ba_no,@mobile_no, @company_id, @company_code, @billing_system, @vat_rate
end

go

