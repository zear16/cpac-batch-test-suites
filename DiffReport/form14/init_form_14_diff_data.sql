use PMDB

go

declare cur cursor for
  select CS.MOBILE_NO, C.COMPANY_ID
  from PM_V_CUST_PROFILE CS
  inner join PM_COMPANY C on (CS.INVOICING_COMPANY = C.COMPANY_ABBR)
  where CS.CHARGE_TYPE = 'Pre-paid'
  and CS.MOBILE_STATUS = 'Active'
  and CS.BILLING_SYSTEM in ('BOS', 'INS')
  and CS.MOBILE_NO in ('0800093849', '0854083836', '0819043667', '0854070669', '0901073429', '0819039971', '0811086314')

go

declare @mobile_no     varchar(20)
declare @company_id    unsigned bigint
declare @sub_bop_id    unsigned bigint
declare @refund_date   date
declare @project_code  varchar(20)
declare @refund_amt    decimal(14,2)
declare @sub_cause_id  unsigned bigint
declare @acc_reason_id unsigned bigint
declare @vat_rate      decimal(5,2)
declare @non_vat_amt   decimal(14,2)
declare @net_vat_amt   decimal(14,2)
declare @vat_amt       decimal(14,2)
declare @total_amt     decimal(14,2)
declare @location_code unsigned bigint
declare @cn_type       char(2)
declare @category_code unsigned bigint
declare @cn_id         unsigned bigint
declare @cn_no         varchar(35)
declare @cn_date       char(10)
declare @ret_msg       varchar(250)
declare @bank_code     unsigned bigint
declare @ret_code      int
declare @session_id    varchar(100)

select @sub_bop_id = SUB_BOP_ID
from PM_SUB_BUSINESS_OF_PAYMENT
where SUB_BOP_CODE = 'RE'

select @project_code = 'TEST TERMINATE REFUND'
     , @refund_amt = 125
     , @cn_type = 'NP'
     , @total_amt = 120
     , @non_vat_amt = 0
     , @location_code = 1020
     , @session_id = '329848980283902849382084fds8f90382'

select @refund_date = convert(date, O.DATA_DATE_FR)
from PM_JOB_ORDER O
where O.TEMPLATE_CODE = 'PE_TERMINATE_REFUND_RECONCILE'
and O.RUN_DATE = convert(date, getdate())


select @bank_code = convert(unsigned bigint, FIELD1_VALUE) 
from PM_SYSTEM_ATTRIBUTE_DTL where ATTRIBUTE_CODE = 'CPAC_PARAM'
and DB_VALUE = 'TERMINATE_REFUND_BANK_CODE'

select @sub_cause_id = S.SUB_CAUSE_ID, @acc_reason_id = T.ACC_REASON_ID
from PM_SUB_CAUSE S
inner join PM_TAX_REASON T on (S.TAX_REASON_ID = T.REASON_ID)
where S.SUB_CAUSE_CODE = 'S08'

select @category_code = CATEGORY_CODE
from PM_PAYMENT_CATEGORY
where CATEGORY_ABBR = 'BF'


-- clean up
delete PM_CREDIT_NOTE_PRINT_ITEM
from PM_CREDIT_NOTE_PRINT_ITEM IT
inner join PM_CREDIT_NOTE CN on (IT.CN_ID = CN.CN_ID and IT.CN_DATE = CN.CN_DATE)
where CN.BANK_CODE = @bank_code
and CN.CN_DATE = @refund_date
and CN.REFUND_TOTAL_AMT = @total_amt
and CN.MOBILE_NO in ('0800093849', '0854083836', '0819043667', '0854070669', '0901073429', '0819039971', '0811086314')

delete PM_CREDIT_NOTE_POS
from PM_CREDIT_NOTE_POS T
inner join PM_CREDIT_NOTE CN on (T.CN_ID = CN.CN_ID and T.CN_DATE = CN.CN_DATE)
where CN.BANK_CODE = @bank_code
and CN.CN_DATE = @refund_date
and CN.REFUND_TOTAL_AMT = @total_amt
and CN.MOBILE_NO in ('0800093849', '0854083836', '0819043667', '0854070669', '0901073429', '0819039971', '0811086314')

delete PM_CREDIT_NOTE_PAYMENT
from PM_CREDIT_NOTE_PAYMENT T
inner join PM_CREDIT_NOTE CN on (T.CN_ID = CN.CN_ID and T.CN_DATE = CN.CN_DATE)
where CN.BANK_CODE = @bank_code
and CN.CN_DATE = @refund_date
and CN.REFUND_TOTAL_AMT = @total_amt
and CN.MOBILE_NO in ('0800093849', '0854083836', '0819043667', '0854070669', '0901073429', '0819039971', '0811086314')

delete PM_CREDIT_NOTE_MAP
from PM_CREDIT_NOTE_MAP T
inner join PM_CREDIT_NOTE CN on (T.CN_ID = CN.CN_ID and T.CN_DATE = CN.CN_DATE)
where CN.BANK_CODE = @bank_code
and CN.CN_DATE = @refund_date
and CN.REFUND_TOTAL_AMT = @total_amt
and CN.MOBILE_NO in ('0800093849', '0854083836', '0819043667', '0854070669', '0901073429', '0819039971', '0811086314')

delete PM_CREDIT_NOTE_HISTORY
from PM_CREDIT_NOTE_HISTORY T
inner join PM_CREDIT_NOTE CN on (T.CN_ID = CN.CN_ID and T.CN_DATE = CN.CN_DATE)
where CN.BANK_CODE = @bank_code
and CN.CN_DATE = @refund_date
and CN.REFUND_TOTAL_AMT = @total_amt
and CN.MOBILE_NO in ('0800093849', '0854083836', '0819043667', '0854070669', '0901073429', '0819039971', '0811086314')


delete PM_CREDIT_NOTE_DTL
from PM_CREDIT_NOTE_DTL T
inner join PM_CREDIT_NOTE CN on (T.CN_ID = CN.CN_ID and T.CN_DATE = CN.CN_DATE)
where CN.BANK_CODE = @bank_code
and CN.CN_DATE = @refund_date
and CN.REFUND_TOTAL_AMT = @total_amt
and CN.MOBILE_NO in ('0800093849', '0854083836', '0819043667', '0854070669', '0901073429', '0819039971', '0811086314')


delete PM_CREDIT_NOTE_ADDR
from PM_CREDIT_NOTE_ADDR T
inner join PM_CREDIT_NOTE CN on (T.CN_ID = CN.CN_ID and T.CN_DATE = CN.CN_DATE)
where CN.BANK_CODE = @bank_code
and CN.CN_DATE = @refund_date
and CN.REFUND_TOTAL_AMT = @total_amt
and CN.MOBILE_NO in ('0800093849', '0854083836', '0819043667', '0854070669', '0901073429', '0819039971', '0811086314')


delete PM_CREDIT_NOTE
from PM_CREDIT_NOTE CN
where CN.BANK_CODE = @bank_code
and CN.CN_DATE = @refund_date
and CN.REFUND_TOTAL_AMT = @total_amt
and CN.MOBILE_NO in ('0800093849', '0854083836', '0819043667', '0854070669', '0901073429', '0819039971', '0811086314')

delete from PM_REFUND_TRANSACTION
where REFUND_DATE = @refund_date
and MOBILE_NO in ('0812079613', '0854082988', '0800020895', '0817028251', '0801064678', '0817055098', '0817064080')


-- GEN CREDIT NOTE

open cur

fetch next cur into @mobile_no, @company_id

while (@@sqlstatus = 0)
begin
  execute @ret_code = dbo.PM_S_CAL_NET_VAT @mobile_no, @total_amt, @refund_date
                             , @vat_rate out, @net_vat_amt out, @vat_amt out, @ret_msg out

  if (@ret_code != 0)
  begin
    print 'execute dbo.PM_S_CAL_NET_VAT %1! failed', @mobile_no
  end
  else
  begin

    execute @ret_code = dbo.PM_S_CREDIT_NOTE_MOBILE
            @mobile_no, @acc_reason_id, @acc_reason_id
          , @vat_rate, @non_vat_amt, @net_vat_amt, @vat_amt
          , 'CLMD', @location_code, @company_id, null, 'BA'
          , @cn_type, @sub_bop_id, @refund_date
          , 'SA', null, 'NO', null, null
          , @category_code, @bank_code
          , @cn_id out, @cn_no out, @cn_date out, @ret_msg out

    if (@ret_code != 0)
    begin
      print 'execute dbo.PM_S_CREDIT_NOTE_MOBILE %1! failed', @mobile_no
    end

  end

  fetch next cur into @mobile_no, @company_id
  
end

-- TERMINATE REFUND TRANSACTION
insert into PM_REFUND_TRANSACTION(
  REFUND_TYPE, SUB_CAUSE_ID, REFUND_DTM, REFUND_DATE, PROJECT_CODE
  , BA_NO, BA_NAME, MOBILE_NO, AMOUNT, COMPANY_ABBR
  , USER_ID, SESSION_ID, SYSTEM
  , REFUND_STATUS, GEN_CN_BOO, VAT_POSTAL_CD, LOCATION_CODE
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
select 'T', @sub_cause_id, @refund_date, @refund_date, @project_code
, CS.BA_NO, CS.BA_NAME, CS.MOBILE_NO, @refund_amt, CS.INVOICING_COMPANY 
, 'SUYADA', @session_id, CS.BILLING_SYSTEM
, 'SC', 'Y', '10310', @location_code
, 'SUYADA', getdate(), 'SUYADA', getdate()
from PM_V_CUST_PROFILE CS
where CS.CHARGE_TYPE = 'Pre-paid'
and CS.MOBILE_STATUS = 'Active'
and CS.BILLING_SYSTEM in ('BOS', 'INS')
and CS.MOBILE_NO in ('0812079613', '0854082988', '0800020895', '0817028251', '0801064678', '0817055098', '0817064080')


go
