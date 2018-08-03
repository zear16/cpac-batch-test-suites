use PMDB

go

declare cur cursor for
  select CS.BA_NO, CS.MOBILE_NO, convert(decimal(5,2), left(CS.CUS_VAT_RATE,1)), C.COMPANY_ID, C.COMPANY_CODE, CS.BILLING_SYSTEM
  from PM_V_CUST_PROFILE CS
  inner join PM_COMPANY C on (CS.INVOICING_COMPANY = C.COMPANY_ABBR)
  where CS.MOBILE_NO in ('0854050028', '0810076836', '0854065167', '0854074673', '0810027579', '0819088499')
  and CS.CHARGE_TYPE = 'Pre-paid'

go

declare @ret_code        int
declare @ret_msg         varchar(250)

declare @batch_id        unsigned bigint
declare @order_id        unsigned bigint

declare @mobile_no        varchar(20)
declare @ba_no            varchar(30)
declare @transaction_id   varchar(128)
declare @company_id       unsigned bigint
declare @company_code     varchar(2)
declare @recharge_date    date
declare @total_amt        decimal(14,2)
declare @non_vat_amt      decimal(14,2)
declare @net_vat_amt      decimal(14,2)
declare @vat_amt          decimal(14,2)
declare @vat_rate         decimal(5,2)
declare @service_id       unsigned bigint
declare @bank_code        unsigned bigint
declare @category_code    unsigned bigint
declare @document_type_id unsigned bigint
declare @document_type    varchar(2)
declare @sub_bop_id       unsigned bigint
declare @bop_id           unsigned bigint
declare @receipt_no       varchar(50)
declare @bop_code         varchar(2)
declare @channel_code     varchar(2)
declare @billing_system   varchar(5)
declare @method_code      unsigned bigint
declare @location_code    unsigned bigint

select @batch_id = L.BATCH_ID
from PM_PREPAID_LOAD_BATCH L
inner join PM_JOB_ORDER O on (L.ORDER_ID = O.ORDER_ID)
where O.TEMPLATE_CODE = 'PE_MPAY_TOPUP'
and O.RUN_DATE = '20170123'
and O.ORDER_TYPE = 'I'

select top 1 @recharge_date = PAYMENT_DATE
from PM_BATCH_MPAY_TOPUP
where BATCH_ID = @batch_id

select @order_id = ORDER_ID
from PM_PREPAID_LOAD_BATCH
where BATCH_ID = @batch_id

select @service_id = 40
     , @location_code = 1020
     , @total_amt = 10

select @bank_code = R.BANK_CODE, @category_code = C.CATEGORY_CODE, @sub_bop_id = C.RC_SUB_BOP_ID, @bop_id = B.BOP_ID, @bop_code = P.BOP_CODE, @channel_code = CH.CHANNEL_CODE
from PM_RECHARGE_SERVICE R
inner join PM_CFG_RECHARGE_SERVICE C on (R.SERVICE_ROW_ID = C.SERVICE_ROW_ID)
inner join PM_SUB_BUSINESS_OF_PAYMENT B on (C.RC_SUB_BOP_ID = B.SUB_BOP_ID)
inner join PM_BUSINESS_OF_PAYMENT P on (B.BOP_ID = P.BOP_ID)
inner join PM_PAYMENT_CATEGORY CT on (C.CATEGORY_CODE = CT.CATEGORY_CODE)
inner join PM_PAYMENT_CHANNEL CH on (CT.CHANNEL_ID = CH.CHANNEL_ID)
where R.SERVICE_ID = @service_id

select @document_type = DOCUMENT_TYPE, @document_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = 'B'

select @method_code = METHOD_CODE
from PM_PAYMENT_METHOD
where METHOD_ABBR = 'CA'


-- clean up

delete from PM_RECHARGE
where RECHARGE_DATE = @recharge_date
and RECHARGE_CHANNEL = @service_id
and RECHARGE_PARTNER_ID = @bank_code
and CREATED_BY = 'SUYADA'
and MOBILE_NO in ('0854050028', '0810076836', '0854065167', '0854074673', '0810027579', '0819088499')

print 'delete PM_RECHARGE %1! records', @@rowcount

----

open cur
fetch next cur into @ba_no, @mobile_no, @vat_rate, @company_id, @company_code, @billing_system

while (@@sqlstatus = 0)
begin

  execute @ret_code = PM_S_GEN_DOC_NO 'CLMD', @company_code, @bop_code
     , @document_type, @channel_code, @location_code, null, '6001', 1
     , @receipt_no out, @ret_msg out

  select @total_amt = @total_amt + 10

  execute @ret_code = dbo.PM_S_CAL_NET_VAT @mobile_no, @total_amt
     , @recharge_date, @vat_rate out, @net_vat_amt out, @vat_amt out
     , @ret_msg out

  insert into PM_RECHARGE(
  BATCH_ID, TRANSACTION_ID, IS_TEST_NUMBER_BOO
  , COMPANY_ID, USER_TYPE, TRANSACTION_DTM
  , MOBILE_NO, ACCOUNT_ID
  , SINGLE_BAL_BOO, CHANNEL
  , RECHARGE_AMT, RECHARGE_DATE
  , RECHARGE_CHANNEL, RECHARGE_PARTNER_ID
  , RECEIPT_NO, RECEIPT_DATE, RECEIPT_LOCATION_CODE
  , RECEIPT_STATUS, RECEIPT_AMT, RECEIPT_BAL, DOCUMENT_TYPE_ID
  , RECEIPT_NON_VAT_AMT, RECEIPT_NET_VAT_AMT, RECEIPT_VAT_AMT
  , CATEGORY_CODE, METHOD_CODE, CONVERT_TO_RECEIPT_BOO
  , BILLING_SYSTEM 
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD
  )
  values(
    null, newid(), 'N'
  , @company_id, 'Pre-paid', @recharge_date
  , @mobile_no, @ba_no
  , 'Y', 14
  , @total_amt, @recharge_date
  , @service_id, @bank_code
  , @receipt_no, @recharge_date, @location_code
  , 'N', @total_amt, @total_amt, @document_type_id
  , @non_vat_amt, @net_vat_amt, @vat_amt
  , @category_code, @method_code, 'N'
  , @billing_system
  , 'SUYADA', getdate(), 'SUYADA', getdate()
  )

  print 'Insert PM_RECHARGE RECHARGE_ID = %1!', @@identity

  fetch next cur into @ba_no, @mobile_no, @vat_rate, @company_id, @company_code, @billing_system

end


go

