use PMDB

go

declare cur cursor for
  select CS.BA_NO, CS.MOBILE_NO, C.COMPANY_ID, C.COMPANY_ABBR, CS.BILLING_SYSTEM
, case when CS.BILLING_SYSTEM = 'BOS' then '5' else '7' end 
  from PM_V_CUST_PROFILE CS
  inner join PM_COMPANY C on (CS.INVOICING_COMPANY = C.COMPANY_ABBR)
  where CS.MOBILE_NO in ('0802042365', '0812099140', '0854096131', '0801061009', '0812055748', '0817022701', '0817011784')
  and CS.CHARGE_TYPE = 'Pre-paid'

go

declare @mobile_no          varchar(20)
declare @batch_id           unsigned bigint
declare @bank_code          unsigned bigint
declare @start_time         datetime
declare @stop_time          datetime
declare @partial_fee        decimal(14,2)
declare @content_id         varchar(5)
declare @service_package_id char(1)
declare @company_abbr       varchar(5)
declare @company_id         unsigned bigint
declare @ba_no              varchar(30)
declare @billing_system     varchar(5)
declare @i                  int
declare @r                  int
declare @cur_system         varchar(5)
declare @total_amt          decimal(14,2)
declare @adj_batch_id       unsigned bigint
declare @operation_date     date

select @i = 0

select @partial_fee = 70
     , @cur_system = null
     , @total_amt = 70

select @batch_id = L.BATCH_ID
     , @start_time = O.DATA_DATE_FR
     , @stop_time = O.DATA_DATE_TO
     , @operation_date = O.DATA_DATE_FR
from PM_PREPAID_LOAD_BATCH L
inner join PM_JOB_ORDER O on (L.ORDER_ID = O.ORDER_ID)
where O.TEMPLATE_CODE = 'PE_DCB_REFUND_CWDC1'
and O.RUN_DATE = '20170118'

-- clean up
delete from PM_BATCH_DCB
where BATCH_ID = @batch_id
and CREATED_BY = 'SUYADA'
and MOBILE_NO in ('0802042365', '0812099140', '0854096131', '0801061009', '0812055748', '0817022701', '0817011784')
and END_CAUSE = '003'

print 'delete PM_BATCH_DCB %1! records', @@rowcount

delete from PM_ADJUST_BOS
where OPERATION_DATE = @operation_date
and (TRANSPARENT_DATA_1 = 'cPAC' or TRANSPARENT_DATA_1 = 'CPAC')
and TRANSPARENT_DATA_2 = 'GOOGLE_REFUND'
and CREATED_BY = 'SUYADA'
and REMARKS = 'TEST_DIFF'
and MOBILE_NO in ('0802042365', '0812099140', '0854096131', '0801061009', '0812055748', '0817022701', '0817011784')

print 'delete PM_ADJUST_BOS %1! records', @@rowcount
---------


open cur

fetch next cur into @ba_no, @mobile_no, @company_id, @company_abbr, @billing_system, @service_package_id

while (@@sqlstatus = 0)
begin
  select @i = @i + 1
  select @r = @i%3

  if (@r = 0)
  begin
    select @content_id = '186'
  end
  if (@r = 1)
  begin
    select @content_id = '105'
  end
  if (@r = 2)
  begin
    select @content_id = '50001'
  end

  select @bank_code = BANK_CODE
  from PM_CONTENT_PARTNER_MAPPING
  where CAUSE_ID = '003'
  and CONTENT_ID = convert(bigint, @content_id)


-- PM_BATCH_DCB

  insert into PM_BATCH_DCB(
    BATCH_ID, BANK_CODE, TRANSACTION_ID
  , MOBILE_NO, APPLICATION_ID, APPLICATION_MENU
  , START_TIME, STOP_TIME, END_CAUSE, SERVICE_PACKAGE_ID
  , PARTIAL_FEE
  , SERVICE_ID, CATEGORY_ID, CONTENT_ID, SERVICE_PV_NAME_MO
  , RECORD_STATUS, BILLING_SYSTEM
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD
  )
  values(
    @batch_id, @bank_code, newid()
  , @mobile_no, '66*3999999', 'Google-Play'
  , @start_time, @stop_time, '003', @service_package_id
  , @partial_fee
  , '299999', '300', @content_id, @company_abbr
  , 'SC', @billing_system
  , 'SUYADA', getdate(), 'SUYADA', getdate()
  )


-- PM_ADJUST_BOS
  if (@cur_system <> @billing_system)
  begin
    select top 1 @adj_batch_id = L.BATCH_ID
    from PM_PREPAID_LOAD_BATCH L
    inner join PM_JOB_ORDER O on (L.ORDER_ID = O.ORDER_ID)
    where O.TEMPLATE_CODE = case when @billing_system = 'BOS' then 'PE_ADJUST_BOS' else 'PE_ADJUST_INS' end
    and O.DATA_DATE_FR = @operation_date
    and L.PROCESS_STATUS = 'SC'

    select @bank_code = case when @billing_system = 'BOS' then 800 else 801 end

  end

  select @cur_system = @billing_system

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
  , TRANSPARENT_DATA_1, TRANSPARENT_DATA_2, TRANSPARENT_DATA_3, REMARKS
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD
  )
values(
    @adj_batch_id, newid()
  , @mobile_no, 'Pre-paid'
  , 1, 1, 'Active'
  , '3G', 'B', 'Standard', 'N'
  , @company_id, 'Mobile', 'Pre-paid'
  , convert(bigint, @ba_no), 'Y', 8001
  , @operation_date, @operation_date, 'Add Amount', 0, @total_amt
  , '0', convert(varchar(20), @total_amt)
  , 'Normal', ' Normal', ' Normal', 'Normal'
  , 0.00, 0.00, 1
  , @billing_system
  , 'CPAC', 'GOOGLE_REFUND', convert(varchar(10), @bank_code), 'TEST_DIFF'
  , 'SUYADA', getdate(), 'SUYADA', getdate()
  )

  fetch next cur into @ba_no, @mobile_no, @company_id, @company_abbr, @billing_system, @service_package_id

end

go

