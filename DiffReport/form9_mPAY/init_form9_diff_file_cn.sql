use PMDB

go

declare cur cursor for
  select CS.BA_NO, CS.MOBILE_NO, convert(decimal(5,2), left(CS.CUS_VAT_RATE,1)), C.COMPANY_ID, C.COMPANY_CODE, CS.BILLING_SYSTEM
  from PM_V_CUST_PROFILE CS
  inner join PM_COMPANY C on (CS.INVOICING_COMPANY = C.COMPANY_ABBR)
  where CS.CHARGE_TYPE = 'Pre-paid'
  and CS.MOBILE_STATUS = 'Active'
  and CS.MOBILE_NO in ('0810024732', '0854075047', '0800018930', '0901049610', '0800039273', '0800025671', '0817037644', '0817013965', '0854025285', '0854063519', '0801016417', '0902001226', '0817061917', '0854030030')
  order by CS.BILLING_SYSTEM
go

declare @batch_id         unsigned bigint
declare @company_id       unsigned bigint
declare @company_code     varchar(2)
declare @mobile_no        varchar(20)
declare @ba_no            varchar(30)
declare @payment_date   date
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
declare @sequence_no      int

declare @err              int


select @payment_date = '20170120'
     , @cur_system = null
     , @total_amt = 77.77
     , @non_vat_amt = 0
     , @bank_code = 500
     , @sub_bop_code = 'RV'
     , @category_abbr = 'RV'
     , @document_type = 'C'
     , @err = 0

select @cn_date = @payment_date

select @document_type_id = DOCUMENT_TYPE_ID from PM_DOCUMENT_TYPE where DOCUMENT_TYPE = @document_type

select @channel_id = CH.CHANNEL_ID, @channel_code = CH.CHANNEL_CODE, @category_code = CT.CATEGORY_CODE
from PM_PAYMENT_CATEGORY CT
inner join PM_PAYMENT_CHANNEL CH on (CT.CHANNEL_ID = CH.CHANNEL_ID)
where CT.CATEGORY_ABBR = @category_abbr

select @bop_id = S.BOP_ID, @sub_bop_id = S.SUB_BOP_ID, @bop_code = B.BOP_CODE
from PM_SUB_BUSINESS_OF_PAYMENT S
inner join PM_BUSINESS_OF_PAYMENT B on (S.BOP_ID = B.BOP_ID)
where S.SUB_BOP_CODE = @sub_bop_code


select @batch_id = L.BATCH_ID
     , @payment_date = O.DATA_DATE_FR
from PM_PREPAID_LOAD_BATCH L
inner join PM_JOB_ORDER O on (L.ORDER_ID = O.ORDER_ID)
where O.TEMPLATE_CODE = 'PE_MPAY_REVERSAL'
and O.DATA_DATE_FR = @payment_date

select @sequence_no = max(convert(int, SEQUENCE_NO))
from PM_BATCH_RVS
where BATCH_ID = @batch_id

select @sequence_no = @sequence_no + 1

-- clean up PM_BATCH_RVS
delete from PM_BATCH_RVS
where BATCH_ID = @batch_id
and CREATED_BY = 'SUYADA'
and TOPUP_MOBILE_NO in ('0810024732', '0854075047', '0800018930', '0901049610', '0800039273', '0800025671', '0817037644', '0817013965', '0854025285', '0854063519', '0801016417', '0902001226', '0817061917', '0854030030')
and BANK_CODE = 500

print 'delete PM_BATCH_RVS %1! records', @@rowcount


-- cleanup PM_CREDIT_NOTE
delete PM_CREDIT_NOTE_DTL
from PM_CREDIT_NOTE_DTL CD
inner join PM_CREDIT_NOTE CN on (CD.CN_ID = CN.CN_ID and CD.CN_DATE = CN.CN_DATE)
where CN.MOBILE_NO in ('0810024732', '0854075047', '0800018930', '0901049610', '0800039273', '0800025671', '0817037644', '0817013965', '0854025285', '0854063519', '0801016417', '0902001226', '0817061917', '0854030030')
and CN.CN_DATE = @cn_date
and CN.CATEGORY_CODE = @category_code
and CN.REFUND_TOTAL_AMT = @total_amt

print 'delete PM_CREDIT_NOTE_DTL %1! records', @@rowcount

delete PM_CREDIT_NOTE
from PM_CREDIT_NOTE CN
where CN.MOBILE_NO in ('0810024732', '0854075047', '0800018930', '0901049610', '0800039273', '0800025671', '0817037644', '0817013965', '0854025285', '0854063519', '0801016417', '0902001226', '0817061917', '0854030030')
and CN.CN_DATE = @cn_date
and CN.CATEGORY_CODE = @category_code
and CN.REFUND_TOTAL_AMT = @total_amt

print 'delete PM_CREDIT_NOTE %1! records', @@rowcount


-------------

open cur

fetch next cur into @ba_no,@mobile_no, @vat_rate, @company_id, @company_code, @billing_system

while (@@sqlstatus = 0)
begin

-- PM_BATCH_RVS

  select @sequence_no = @sequence_no + 1

  insert into PM_BATCH_RVS(
    BATCH_ID, SEQUENCE_NO, BANK_CODE, COMPANY_ID
    , PAYMENT_DATE, PAYMENT_TIME, TOPUP_MOBILE_NO
    , TRANSACTION_ID, TRANSACTION_CODE
    , TOPUP_AMT, REVERSAL_AMT
    , BATCH_NO, NETWORK_TYPE
    , BILLING_SYSTEM
    , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD
  )
  values(
    @batch_id, convert(varchar(6), @sequence_no), @bank_code, @company_id
    , @payment_date, '20:00:00', @mobile_no
    , newid(), 'RVS'
    , @total_amt, @total_amt
    , 'batchrvs000000' || convert(varchar(10), @sequence_no), '3G'
    , @billing_system
    , 'SUYADA', getdate(), 'SUYADA', getdate()
  )



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

