use PMDB

go

declare cur  cursor for
  select CS.BA_NO, CS.MOBILE_NO, C.COMPANY_ID, C.COMPANY_CODE, CS.BILLING_SYSTEM, convert(decimal(5,2), left(CS.CUS_VAT_RATE,1))
  from PM_V_CUST_PROFILE CS
  inner join PM_COMPANY C on (CS.INVOICING_COMPANY = C.COMPANY_ABBR)
  where CS.CHARGE_TYPE = 'Pre-paid'
  and CS.MOBILE_STATUS = 'Active'
  and CS.MOBILE_NO in ('0817057150', '0854022988', '0954001664', '0817097482', '0901018129', '0819061634', '0901013476', '0800035619', '0854065306')
  order by CS.BILLING_SYSTEM

go

declare @batch_id         unsigned bigint
declare @mobile_no        varchar(20)
declare @ba_no            varchar(32)
declare @company_id       unsigned bigint
declare @company_code     varchar(2)
declare @product_id       unsigned bigint
declare @product_name     univarchar(250)
declare @service_id       unsigned bigint
declare @total_amt        decimal(14,2)
declare @non_vat_amt      decimal(14,2)
declare @net_vat_amt      decimal(14,2)
declare @vat_amt          decimal(14,2)
declare @vat_rate         decimal(5,2)
declare @billing_system   varchar(5)

declare @receipt_no       varchar(50)
declare @receipt_id       unsigned bigint
declare @receipt_date     date
declare @receipt_dtl_id   unsigned bigint
declare @bank_code        unsigned bigint
declare @document_type    varchar(1) 
declare @document_type_id unsigned bigint
declare @channel_id       unsigned bigint
declare @channel_code     varchar(2)
declare @category_code    unsigned bigint
declare @category_abbr    varchar(2)
declare @bop_code         varchar(2)
declare @bop_id           unsigned bigint
declare @sub_bop_code     varchar(2)
declare @sub_bop_id       unsigned bigint
declare @location_code    unsigned bigint

declare @ret_code         int
declare @ret_msg          varchar(250)

select @receipt_date = '20170124'
     , @category_abbr = 'PV'
     , @sub_bop_code = 'DV'
     , @location_code = 1020
     , @document_type = 'B'
     , @non_vat_amt = 0


select @document_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = @document_type

select top 1 @batch_id = L.BATCH_ID
from PM_PREPAID_LOAD_BATCH L
inner join PM_JOB_ORDER O on (L.ORDER_ID = O.ORDER_ID)
where O.TEMPLATE_CODE = 'PE_PACKAGE_BOS'
and O.ORDER_TYPE = 'I'
and O.DATA_DATE_FR = @receipt_date

select @channel_id = CH.CHANNEL_ID, @channel_code = CH.CHANNEL_CODE
     , @category_code = CT.CATEGORY_CODE
from PM_PAYMENT_CATEGORY CT
inner join PM_PAYMENT_CHANNEL CH on (CT.CHANNEL_ID = CH.CHANNEL_ID)
where CT.CATEGORY_ABBR = @category_abbr

select @bop_id = B.BOP_ID, @bop_code = B.BOP_CODE, @sub_bop_id = SB.SUB_BOP_ID
from PM_SUB_BUSINESS_OF_PAYMENT SB
inner join PM_BUSINESS_OF_PAYMENT B on (SB.BOP_ID = B.BOP_ID)
where SB.SUB_BOP_CODE = @sub_bop_code


select @product_id = P.PACKAGE_CODE, @product_name = P.PACKAGE_NAME
     , @bank_code = P.BANK_CODE, @total_amt = P.PACKAGE_FEE
     , @service_id = R.SERVICE_ID
from PM_PACKAGE P
inner join PM_RECHARGE_SERVICE R on (P.BANK_CODE = R.BANK_CODE)
where P.PACKAGE_CODE = 171601

-- clean up PM_PACKAGE_BOS
delete PM_PACKAGE_BOS
from PM_PACKAGE_BOS P
inner join PM_RECEIPT R on (P.RECEIPT_ID = R.RECEIPT_ID and P.RECEIPT_DATE = R.RECEIPT_DATE)
where R.RECEIPT_DATE = @receipt_date
and R.CREATED_BY = 'SUYADA'
and R.MOBILE_NO in ('0817057150', '0854022988', '0954001664', '0817097482', '0901018129', '0819061634', '0901013476', '0800035619', '0854065306')
and R.CATEGORY_CODE = @category_code

-- clean up PM_RECEIPT
delete PM_RECEIPT_DTL_PREPAID
from PM_RECEIPT_DTL_PREPAID RDP
inner join PM_RECEIPT_DTL RD on (RDP.RECEIPT_DTL_ID = RD.RECEIPT_DTL_ID and RDP.RECEIPT_DATE = RD.RECEIPT_DATE)
inner join PM_RECEIPT R on (RD.RECEIPT_ID = R.RECEIPT_ID and RD.RECEIPT_DATE = R.RECEIPT_DATE)
where  R.RECEIPT_DATE = @receipt_date
and R.CREATED_BY = 'SUYADA'
and R.MOBILE_NO in ('0817057150', '0854022988', '0954001664', '0817097482', '0901018129', '0819061634', '0901013476', '0800035619', '0854065306')
and R.CATEGORY_CODE = @category_code

delete PM_RECEIPT_PREPAID
from PM_RECEIPT_PREPAID RP
inner join PM_RECEIPT R on (RP.RECEIPT_ID = R.RECEIPT_ID and RP.RECEIPT_DATE = R.RECEIPT_DATE)
where  R.RECEIPT_DATE = @receipt_date
and R.CREATED_BY = 'SUYADA'
and R.MOBILE_NO in ('0817057150', '0854022988', '0954001664', '0817097482', '0901018129', '0819061634', '0901013476', '0800035619', '0854065306')
and R.CATEGORY_CODE = @category_code


delete PM_RECEIPT_DTL
from PM_RECEIPT_DTL P
inner join PM_RECEIPT R on (P.RECEIPT_ID = R.RECEIPT_ID and P.RECEIPT_DATE = R.RECEIPT_DATE)
where R.RECEIPT_DATE = @receipt_date
and R.CREATED_BY = 'SUYADA'
and R.MOBILE_NO in ('0817057150', '0854022988', '0954001664', '0817097482', '0901018129', '0819061634', '0901013476', '0800035619', '0854065306')
and R.CATEGORY_CODE = @category_code

delete PM_RECEIPT
from PM_RECEIPT R
where R.RECEIPT_DATE = @receipt_date
and R.CREATED_BY = 'SUYADA'
and R.MOBILE_NO in ('0817057150', '0854022988', '0954001664', '0817097482', '0901018129', '0819061634', '0901013476', '0800035619', '0854065306')
and R.CATEGORY_CODE = @category_code

------------------------

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
    , 'SUYADA', getdate(), 'SUYADA', getdate()
  )

  print 'insert PM_RECEIPT %1! record', @@rowcount

  select @receipt_id = @@identity

  insert into PM_RECEIPT_PREPAID(
    RECEIPT_ID, RECEIPT_DATE, SERVICE_ID
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD
  )
  values(
    @receipt_id, @receipt_date, @service_id
  , 'SUYADA', getdate(), 'SUYADA', getdate()
  )

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
    , 'SUYADA', getdate(), 'SUYADA', getdate()
  )

  print 'insert PM_RECEIPT_DTL %1! record', @@rowcount

  select @receipt_dtl_id = @@identity

  insert into PM_RECEIPT_DTL_PREPAID (
    RECEIPT_DTL_ID, RECEIPT_DATE, PREPAID_BATCH_NO, PREPAID_SERIAL_NO
  , DEDUCT_BOO, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD
  )
  values(
    @receipt_dtl_id, @receipt_date, 'EPIN01293', convert(varchar(20), @receipt_id )
  , 'N', 'SUYADA', getdate(), 'SUYADA', getdate()
  )



-- insert PM_PACKAGE_BO



  insert into PM_PACKAGE_BOS(
    BATCH_ID, MOBILE_NO, MAIN_PRODUCT_ID, MAIN_PRODUCT_SEQ_ID, BRAND
  , CUSTOMER_SEGMENT, SUBSCRIBER_SEGMENT, IS_TEST_NUMBER_BOO
  , COMPANY_ID, NON_MOBILE, USER_TYPE
  , ACCOUNT_ID, SINGLE_BAL_BOO
  , PRODUCT_ID, PRODUCT_SEQUENCE_ID, PRODUCT_NAME, PRODUCT_LEVEL
  , IS_MAIN_BOO, CHANNEL, OPERATION_DTM, USER_ID
  , PRODUCT_PRICE_VALUE, INCLUDE_TAX_BOO, RECEIPT_ID, RECEIPT_DATE
  , BILLING_SYSTEM, OPERATION_DATE
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD
  )
  values(
    @batch_id, @mobile_no, 1, 1, '3G'
  , 'B', 'Standard', 'N'
  , @company_id, 'Mobile', 'Pre-paid'
  , convert(unsigned bigint, @ba_no), 'Y'
  , @product_id, 100000035583, @product_name, 0
  , 'Y', 14, @receipt_date, 'CLMD'
  , 0, '2', @receipt_id, @receipt_date
  , @billing_system, @receipt_date
  , 'SUYADA', getdate(), 'SUYADA', getdate()
  )


  fetch next cur into @ba_no,@mobile_no, @company_id, @company_code, @billing_system, @vat_rate

end

go

