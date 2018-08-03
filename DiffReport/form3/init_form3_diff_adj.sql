use PMDB

go

declare cur cursor for
  select CS.BA_NO, CS.MOBILE_NO, C.COMPANY_ID, CS.BILLING_SYSTEM
  from PM_V_CUST_PROFILE CS
  inner join PM_COMPANY C on (CS.INVOICING_COMPANY = C.COMPANY_ABBR)
  where CS.CHARGE_TYPE = 'Pre-paid'
  and CS.MOBILE_STATUS = 'Active'
  and   CS.MOBILE_NO in ('0818000082', '0810098481', '0811016351', '0901096352', '0854016821', '0854099949', '0812012884', '0854097506', '0901021990', '0854064623', '0810061293', '0819035480', '0800073287', '0901081137', '0901084384', '0817066135', '0854059610')
  order by CS.BILLING_SYSTEM
go

declare @batch_id       unsigned bigint
declare @company_id     unsigned bigint
declare @mobile_no      varchar(20)
declare @ba_no          varchar(30)
declare @operation_date date
declare @total_amt      decimal(14,2)
declare @billing_system varchar(5)
declare @bank_code      unsigned bigint

declare @cur_system     varchar(5)

select @operation_date = '20170117'
     , @cur_system = null
     , @total_amt = 130

-- cleanup
delete from PM_ADJUST_BOS
where OPERATION_DATE = @operation_date
and (TRANSPARENT_DATA_1 = 'CPAC' or TRANSPARENT_DATA_1 = 'cPAC')
and TRANSPARENT_DATA_2 = 'GOOGLE_REFUND'
and CREATED_BY = 'SUYADA'
and REMARKS = 'TEST_DIFF'
and MOBILE_NO in ('0818000082', '0810098481', '0811016351', '0901096352', '0854016821', '0854099949', '0812012884', '0854097506', '0901021990', '0854064623', '0810061293', '0819035480', '0800073287', '0901081137', '0901084384', '0817066135', '0854059610')

print 'delete PM_ADJUST_BOS %1! records', @@rowcount
-------------

open cur

fetch next cur into @ba_no,@mobile_no, @company_id, @billing_system

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
    @batch_id, newid()
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

  fetch next cur into @ba_no,@mobile_no, @company_id, @billing_system
end

go

