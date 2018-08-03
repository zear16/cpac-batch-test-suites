use PMDB

go

declare rc_cur cursor for
  select CS2.MOBILE_NO, CS2.BA_NO, C2.COMPANY_ID, C2.COMPANY_CODE
  from PM_V_CUST_PROFILE CS2, PM_COMPANY C2
  where CS2.MOBILE_NO in ('0811059704', '0817083406', '0901057702', '0901038440', '0810022038', '0811023605', '0818055111', '0812014318', '0819090911', '0810037545', '0800023526', '0901067996', '0802081089')
  and CS2.INVOICING_COMPANY = C2.COMPANY_ABBR

go

declare cn_cur cursor for
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

select @adjust_amt = 49
    , @non_vat_amt = 0
    , @bank_code = 804

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

open cn_cur

open rc_cur

fetch next cn_cur into @wrong_mobile_no, @wrong_ba_no, @wrong_company_id, @wrong_company_code

fetch next rc_cur into @topup_mobile_no, @topup_ba_no, @topup_company_id, @topup_company_code

while (@@sqlstatus = 0)
begin

-- wrong number
  select @trans_no = convert(bigint, '03' || dbo.PM_F_FORMAT_DATE(getdate(), 'HH24MISS') || @wrong_mobile_no)

  insert into PM_ADJUST_TRANSACTION
  (TRANS_NO, MOBILE_NO, REF_MOBILE_NO, ACCOUNT_NO, COMPANY_ID
  , BANK_CODE, SERVICE_ID, COST_CENTER_ID, SUB_CAUSE_ID, LOCATION_CODE
  , ADJUST_AMT, ADJUST_VALIDITY, ADJUST_DTM, ADJUST_DATE, GEN_CN_BOO
  , CN_ID, CN_DATE, CN_NO
  , REMARK, ADJUST_STATUS, BILLING_SYSTEM
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@trans_no, @wrong_mobile_no, null, @wrong_ba_no, 6
  , 2, 1, null, @wrong_number_sub_cause_id, 1020
  , -1*@adjust_amt, 0,  @adjust_date, @adjust_date, 'Y'
  , @cn_id, @cn_date, @cn_no
  , null, 'SC', 'BOS'
  , 'SUYADA', getdate(), 'SUYADA', getdate()
  )

  print 'create ADJUST TRANS (-)'

  select @adjust_id = @@identity

  insert into PM_ADJUST_TRANSACTION
  (TRANS_NO, MOBILE_NO, REF_MOBILE_NO, ACCOUNT_NO, COMPANY_ID
  , BANK_CODE, SERVICE_ID, COST_CENTER_ID, SUB_CAUSE_ID, LOCATION_CODE
  , ADJUST_AMT, ADJUST_VALIDITY, ADJUST_DTM, ADJUST_DATE, GEN_CN_BOO
  , RECEIPT_ID, RECEIPT_NO, RECEIPT_DATE
  , REMARK, ADJUST_STATUS, BILLING_SYSTEM
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@trans_no, @topup_mobile_no, @wrong_mobile_no, @topup_ba_no, 6
  , 2, 1, null, @wrong_number_sub_cause_id, @location_code
  , @adjust_amt, 0,  @adjust_date, @adjust_date, 'N'
  , @receipt_id, @receipt_no, @receipt_date
  , null, 'SC', 'BOS'
  , 'SUYADA', getdate(), 'SUYADA', getdate()
  )

  print 'create ADJUST TRANS (+)'


  fetch next cn_cur into @wrong_mobile_no, @wrong_ba_no, @wrong_company_id, @wrong_company_code

  fetch next rc_cur into @topup_mobile_no, @topup_ba_no, @topup_company_id, @topup_company_code


end

go

