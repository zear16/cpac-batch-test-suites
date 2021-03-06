use PMDB

go

declare cur cursor for
  select CS.MOBILE_NO, CS.BA_NO, C1.COMPANY_ID, C1.COMPANY_CODE
  from PM_V_CUST_PROFILE CS, PM_COMPANY C1
  where CS.MOBILE_NO in ('0819043982', '0901071169', '0901046801', '0810044940', '0910000321', '0812017135', '0810012111', '0817073209', '0802093509', '0854060142', '0810054477', '0811012334', '0818084421')
  and CS.INVOICING_COMPANY = C1.COMPANY_ABBR

go

print 'after query mobile'

declare @trans_no                  unsigned bigint
declare @wrong_number_sub_cause_id unsigned bigint
declare @wrong_mobile_no           varchar(20)
declare @topup_mobile_no           varchar(20)
declare @wrong_ba_no               varchar(32)
declare @topup_ba_no               varchar(32)
declare @wrong_company_id          unsigned bigint
declare @wrong_company_code        varchar(1)
declare @topup_company_id          unsigned bigint
declare @topup_company_code        varchar(1)
declare @adjust_id                 unsigned bigint
declare @adjust_date               date
declare @receipt_id                unsigned bigint
declare @receipt_no                varchar(32)
declare @receipt_date              date
declare @cn_id                     unsigned bigint
declare @cn_date                   date
declare @cn_no                     varchar(32)

declare @total_amt                 decimal(14,2)
declare @adjust_amt                decimal(14,2)
declare @non_vat_amt               decimal(14,2)
declare @net_vat_amt               decimal(14,2)
declare @vat_amt                   decimal(14,2)
declare @vat_rate                  decimal(5,2)

declare @location_code             unsigned bigint

declare @cn_doc_type               varchar(2)
declare @cn_doc_type_id            unsigned bigint
declare @rc_doc_type               varchar(2)
declare @rc_doc_type_id            unsigned bigint

declare @sub_bop_code              varchar(2)
declare @sub_bop_id                unsigned bigint
declare @bop_code                  varchar(2)
declare @bop_id                    unsigned bigint
declare @category_code             unsigned bigint
declare @category_abbr             varchar(2)
declare @channel_code              varchar(2)
declare @channel_id                unsigned bigint
declare @bank_code                 unsigned bigint

declare @ret_msg                   varchar(250)
declare @ret_code                  int


-- Init Adjust Transaction + CN

select @adjust_date = O.DATA_DATE_FR
, @receipt_date = O.DATA_DATE_FR
, @cn_date = O.DATA_DATE_FR
from PM_JOB_ORDER O
where O.TEMPLATE_CODE = 'PE_WRONG_NUMBER_RECONCILE'
and O.RUN_DATE = convert(date, getdate())


select @wrong_number_sub_cause_id = C.SUB_CAUSE_ID
from PM_SYSTEM_ATTRIBUTE_DTL A
inner join PM_SUB_CAUSE C on (A.FIELD1_VALUE = C.SUB_CAUSE_CODE)
where A.ATTRIBUTE_CODE = 'CPAC_PARAM'
and A.DB_VALUE = 'WRONG_NUMBER_SUB_CAUSE'

select @total_amt = 120
    , @non_vat_amt = 0
    , @bank_code = 804
    , @topup_mobile_no = '0811059704'

select @bop_id = B.BOP_ID, @bop_code = B.BOP_CODE
     , @sub_bop_id = SB.SUB_BOP_ID, @sub_bop_code = SB.SUB_BOP_CODE
from PM_SUB_BUSINESS_OF_PAYMENT SB
inner join PM_BUSINESS_OF_PAYMENT B on (SB.BOP_ID = SB.BOP_ID)
where SB.SUB_BOP_CODE = 'PT'

select @channel_id = CH.CHANNEL_ID, @channel_code = CH.CHANNEL_CODE
     , @category_code = CT.CATEGORY_CODE, @category_abbr = CT.CATEGORY_ABBR
from PM_PAYMENT_CATEGORY CT 
inner join PM_PAYMENT_CHANNEL CH on (CT.CHANNEL_ID = CH.CHANNEL_ID)
where CT.CATEGORY_ABBR = 'BF'

select @cn_doc_type = DOCUMENT_TYPE, @cn_doc_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE 
where DOCUMENT_TYPE = 'C'

select @rc_doc_type = DOCUMENT_TYPE, @rc_doc_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE
where DOCUMENT_TYPE = 'B'

open cur

fetch next cur into @wrong_mobile_no, @wrong_ba_no, @wrong_company_id, @wrong_company_code

while (@@sqlstatus = 0)
begin

  select @total_amt = 89

-- wrong number
  execute @ret_code = dbo.PM_S_CAL_NET_VAT @wrong_mobile_no, @total_amt, @adjust_date
                   , @vat_rate out, @net_vat_amt out, @vat_amt out, @ret_msg out


  execute @ret_code = PM_S_GEN_DOC_NO 'CLMD', @wrong_company_code, @bop_code
     , @cn_doc_type, @channel_code, @location_code, null, '6001', 1
     , @cn_no out, @ret_msg out

  if (@ret_code <> 0)
  begin
    print 'Gen doc no for credit note failed'
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
    @wrong_company_id, @cn_doc_type_id, 1
    , @cn_no, @cn_date, 'BA', @location_code, @channel_id, @category_code, @bop_id
    , 'N', getdate(), 'NO', 'N', 'NP'
    , 'MO', 'CLMD'
    , @non_vat_amt, @net_vat_amt, @vat_amt, @total_amt
    , @non_vat_amt, @net_vat_amt, @vat_amt, @total_amt
    , 0, 0, 0, 0
    , 'SA', @wrong_ba_no, @wrong_mobile_no, @bank_code
    , 'SUYADA', getdate(), 'SUYADA', getdate()
  )

  print 'insert PM_CREDIT_NOTE %1! record', @@rowcount

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
    , @sub_bop_id, @wrong_mobile_no
    , 0, @non_vat_amt, @net_vat_amt, @vat_rate, @vat_amt, @total_amt
    , @non_vat_amt, @net_vat_amt, @vat_amt, @total_amt
    , 0, 0, 0, 0
    , 'SUYADA', getdate(), 'SUYADA', getdate()
  )


  insert into PM_CREDIT_NOTE_MAP(
    CN_DATE, CN_ID, REF_DOC_TYPE
    , PREV_NON_VAT_AMT, PREV_NET_VAT_AMT, PREV_VAT_AMT, PREV_TOTAL_AMT
    , REFUND_NON_VAT_AMT, REFUND_NET_VAT_AMT, REFUND_VAT_AMT, REFUND_TOTAL_AMT
    , NON_VAT_BAL, NET_VAT_BAL, VAT_BAL, TOTAL_BAL
    , CN_PARTIAL_BOO
    , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD
  )
  values(
    @cn_date, @cn_id, 'MO'
    , @non_vat_amt, @net_vat_amt, @vat_amt, @total_amt
    , @non_vat_amt, @net_vat_amt, @vat_amt, @total_amt
    , 0, 0, 0, 0
    , 'N'
    , 'SUYADA', getdate(), 'SUYADA', getdate()
  )


  fetch next cur into @wrong_mobile_no, @wrong_ba_no, @wrong_company_id, @wrong_company_code

end

go

