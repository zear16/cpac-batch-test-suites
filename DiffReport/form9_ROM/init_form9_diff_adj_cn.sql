use PMDB

go

declare cur cursor for
  select CS.BA_NO, CS.MOBILE_NO, convert(decimal(5,2), left(CS.CUS_VAT_RATE,1)), C.COMPANY_ID, C.COMPANY_CODE, CS.BILLING_SYSTEM
  from PM_V_CUST_PROFILE CS
  inner join PM_COMPANY C on (CS.INVOICING_COMPANY = C.COMPANY_ABBR)
  where CS.CHARGE_TYPE = 'Pre-paid'
  and CS.MOBILE_STATUS = 'Active'
  and   CS.MOBILE_NO in ('0818000082', '0810098481', '0811016351', '0901096352', '0854016821', '0854099949', '0812012884', '0854097506', '0901021990', '0854064623', '0810061293', '0819035480', '0800073287', '0901081137', '0901084384', '0817066135', '0854059610')
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

declare @ret_code         int
declare @ret_msg          varchar(250)
declare @vat_rate         decimal(5,2)
declare @non_vat_amt      decimal(14,2)
declare @net_vat_amt      decimal(14,2)
declare @vat_amt          decimal(14,2)
declare @cn_no            varchar(30)
declare @cn_date          date
declare @cn_id            unsigned bigint
declare @cn_dtl_id        unsigned bigint
declare @document_type    varchar(2)
declare @document_type_id unsigned bigint
declare @channel_code     varchar(2)
declare @channel_id       unsigned bigint
declare @category_abbr    varchar(2)
declare @category_code    unsigned bigint
declare @location_code    unsigned bigint
declare @sub_bop_code     varchar(2)
declare @sub_bop_id       unsigned bigint
declare @bop_code         varchar(2)
declare @bop_id           unsigned bigint

declare @err              int


select @operation_date = '20170120'
     , @cur_system = null
     , @total_amt = 130
     , @non_vat_amt = 0
     , @bank_code = 501
     , @sub_bop_code = 'RV'
     , @category_abbr = 'RM'
     , @document_type = 'C'
     , @err = 0

select @cn_date = @operation_date

select @document_type_id = DOCUMENT_TYPE_ID from PM_DOCUMENT_TYPE where DOCUMENT_TYPE = @document_type

select @channel_id = CH.CHANNEL_ID, @channel_code = CH.CHANNEL_CODE, @category_code = CT.CATEGORY_CODE
from PM_PAYMENT_CATEGORY CT
inner join PM_PAYMENT_CHANNEL CH on (CT.CHANNEL_ID = CH.CHANNEL_ID)
where CT.CATEGORY_ABBR = @category_abbr

select @bop_id = S.BOP_ID, @sub_bop_id = S.SUB_BOP_ID, @bop_code = B.BOP_CODE
from PM_SUB_BUSINESS_OF_PAYMENT S
inner join PM_BUSINESS_OF_PAYMENT B on (S.BOP_ID = B.BOP_ID)
where S.SUB_BOP_CODE = @sub_bop_code


-- cleanup PM_ADJUST_BOS
delete from PM_ADJUST_BOS
where OPERATION_DATE = @operation_date
and TRANSPARENT_DATA_1 = 'ROMRVS' 
and CREATED_BY = 'SUYADA'
and REMARKS = 'TEST_DIFF_RVS'
and MOBILE_NO in ('0818000082', '0810098481', '0811016351', '0901096352', '0854016821', '0854099949', '0812012884', '0854097506', '0901021990', '0854064623', '0810061293', '0819035480', '0800073287', '0901081137', '0901084384', '0817066135', '0854059610')

print 'delete PM_ADJUST_BOS %1! records', @@rowcount

-- cleanup PM_CREDIT_NOTE
delete PM_CREDIT_NOTE_DTL
from PM_CREDIT_NOTE_DTL CD
inner join PM_CREDIT_NOTE CN on (CD.CN_ID = CN.CN_ID and CD.CN_DATE = CN.CN_DATE)
where CN.MOBILE_NO in ('0818000082', '0810098481', '0811016351', '0901096352', '0854016821', '0854099949', '0812012884', '0854097506', '0901021990', '0854064623', '0810061293', '0819035480', '0800073287', '0901081137', '0901084384', '0817066135', '0854059610')
and CN.CN_DATE = @cn_date
and CN.CATEGORY_CODE = @category_code

print 'delete PM_CREDIT_NOTE_DTL %1! records', @@rowcount

delete PM_CREDIT_NOTE
from PM_CREDIT_NOTE CN
where CN.MOBILE_NO in ('0818000082', '0810098481', '0811016351', '0901096352', '0854016821', '0854099949', '0812012884', '0854097506', '0901021990', '0854064623', '0810061293', '0819035480', '0800073287', '0901081137', '0901084384', '0817066135', '0854059610')
and CN.CN_DATE = @cn_date
and CN.CATEGORY_CODE = @category_code

print 'delete PM_CREDIT_NOTE %1! records', @@rowcount


-------------

open cur

fetch next cur into @ba_no,@mobile_no, @vat_rate, @company_id, @company_code, @billing_system

while (@@sqlstatus = 0)
begin

  if (@cur_system <> @billing_system)
  begin
    select top 1 @batch_id = L.BATCH_ID
    from PM_PREPAID_LOAD_BATCH L
    inner join PM_JOB_ORDER O on (L.ORDER_ID = O.ORDER_ID)
    where O.TEMPLATE_CODE = case when @billing_system = 'BOS' then 'PE_ADJUST_BOS' else 'PE_ADJUST_INS' end
    and O.DATA_DATE_FR = @operation_date
    and L.PROCESS_STATUS = 'SC'
    and O.ORDER_TYPE = 'I'

  end

  select @cur_system = @billing_system


---- PM_ADJUST_BOS ------

  insert into PM_ADJUST_BOS(
    BATCH_ID, TRANSACTION_ID
  , MOBILE_NO, PAYMENT_TYPE
  , MAIN_PRODUCT_ID, MAIN_PRODUCT_SEQUENCE_ID, MAIN_PROMOTION_STATUS
  , BRAND, CUSTOMER_SEGMENT, SUBSCRIBER_SEGMENT, IS_TEST_NUMBER_BOO
  , COMPANY_ID, NON_MOBILE, USER_TYPE
  ,  ACCOUNT_ID, SINGLE_BAL_BOO, SPECIFICATION_ID
  , OPERATION_DTM, OPERATION_DATE, REQUEST_ACTION, ASSET_TYPE, ADJUST_VALUE
  , OLD_VALUE, NEW_VALUE
  , NEW_SUSPEND_FLG, NEW_FRAUD_FLG, NEW_SUSPEND_TYPE, OLD_SUSPEND_TYPE
  , SYS_PREPAID_BAL_LIMIT, NEGATIVE_BAL, CHANNEL
  , BILLING_SYSTEM
  , TRANSPARENT_DATA_1, REMARKS
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD
  )
values(
    @batch_id, newid()
  , @mobile_no, 'Pre-paid'
  , 1, 1, 'Active'
  , '3G', 'B', 'Standard', 'N'
  , @company_id, 'Mobile', 'Pre-paid'
  , convert(bigint, @ba_no), 'Y', 8001
  , @operation_date, @operation_date, 'Deduct Amount', 0, @total_amt
  , '0', convert(varchar(20), @total_amt)
  , 'Normal', ' Normal', ' Normal', 'Normal'
  , 0.00, 0.00, 1
  , @billing_system
  , 'ROMRVS', 'TEST_DIFF_RVS'
  , 'SUYADA', getdate(), 'SUYADA', getdate()
  )

  print 'insert PM_ADJUST_BOS %1! records', @@rowcount

--  PM_CREDIT_NOTE ----------

  execute @ret_code = dbo.PM_S_CAL_NET_VAT @mobile_no, @total_amt, @cn_date                     , @vat_rate out, @net_vat_amt out, @vat_amt out, @ret_msg out

  execute @ret_code = PM_S_GEN_DOC_NO 'CLMD', @company_code, @bop_code
     , @document_type, @channel_code, @location_code, null, '6001', 1
     , @cn_no out, @ret_msg out

  if (@ret_code <> 0)
  begin
    print 'Gen doc no for credit note failed'
    select @err = -1
  end

  insert into PM_CREDIT_NOTE(
    COMPANY_ID, DOCUMENT_TYPE_ID, TEMPLATE_ID
    , CN_NO, CN_DATE, MODE, CN_LOCATION_CODE, CHANNEL_ID, CATEGORY_CODE, BOP_ID
    , CN_STATUS, STATUS_DTM, RECEIPT_SENDING, PRINT_ATTACH_BOO, CN_TYPE
    , REF_DOC_TYPE, USER_ID
    , PREV_NON_VAT_AMT, PREV_NET_VAT_AMT, PREV_VAT_AMT, PREV_TOTAL_AMT
    , REFUND_NON_VAT_AMT, REFUND_NET_VAT_AMT, REFUND_VAT_AMT, REFUND_TOTAL_AMT
    , NON_VAT_BAL, NET_VAT_BAL, VAT_BAL, TOTAL_BAL
    , REFUND_TYPE, BA_NO, MOBILE_NO, BANK_CODE
    , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD
  )
  values(
    @company_id, @document_type_id, 1
    , @cn_no, @cn_date, 'BA', @location_code, @channel_id, @category_code, @bop_id
    , 'N', getdate(), 'NO', 'N', 'NP'
    , 'MO', 'CLMD'
    , 0, 0, 0, 0
    , @non_vat_amt, @net_vat_amt, @vat_amt, @total_amt
    , 0, 0, 0, 0
    , 'SA', @ba_no, @mobile_no, @bank_code
    , 'CLMD', getdate(), 'SUYADA', getdate()
  )

  select @cn_id = @@identity

  insert into PM_CREDIT_NOTE_DTL(
    CN_DATE, CN_ID
    , SUB_BOP_ID, MOBILE_NO
    , DISCOUNT_AMT, NON_VAT_AMT, NET_VAT_AMT, VAT_RATE, VAT_AMT, TOTAL_AMT
    , REFUND_NON_VAT_AMT, REFUND_NET_VAT_AMT, REFUND_VAT_AMT, REFUND_TOTAL_AMT
    , NON_VAT_BAL, NET_VAT_BAL, VAT_BAL, TOTAL_BAL
    , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD
  )
  values(
    @cn_date, @cn_id
    , @sub_bop_id, @mobile_no
    , 0, 0, 0, @vat_rate, 0, 0
    , @non_vat_amt, @net_vat_amt, @vat_amt, @total_amt
    , 0, 0, 0, 0
    , 'CLMD', getdate(), 'SUYADA', getdate()
  )

  fetch next cur into @ba_no,@mobile_no, @vat_rate, @company_id, @company_code, @billing_system

end

go

