use PMDB

go

declare cur cursor for
  select CS.BA_NO, CS.MOBILE_NO, C.COMPANY_ID, C.COMPANY_ABBR, CS.BILLING_SYSTEM
, case when CS.BILLING_SYSTEM = 'BOS' then '5' else '7' end 
  from PM_V_CUST_PROFILE CS
  inner join PM_COMPANY C on (CS.INVOICING_COMPANY = C.COMPANY_ABBR)
  where CS.MOBILE_NO in ('0817066135','0854059610','0810055482','0818038764','0854067640','0802022691','0901071692','0854037358','0801042496','0901035186')
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

select @i = 0

select @partial_fee = 40

select @batch_id = L.BATCH_ID
     , @start_time = O.DATA_DATE_FR
     , @stop_time = O.DATA_DATE_TO
from PM_PREPAID_LOAD_BATCH L
inner join PM_JOB_ORDER O on (L.ORDER_ID = O.ORDER_ID)
where O.TEMPLATE_CODE = 'PE_DCB_REFUND_CWDC1'
and O.RUN_DATE = '20170118'

-- clean up
delete from PM_BATCH_DCB
where BATCH_ID = @batch_id
and CREATED_BY = 'SUYADA'
and MOBILE_NO in ('0817066135','0854059610','0810055482','0818038764','0854067640','0802022691','0901071692','0854037358','0801042496','0901035186')
and END_CAUSE = '003'

print 'delete PM_BATCH_DCB %1! records', @@rowcount
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

  fetch next cur into @ba_no, @mobile_no, @company_id, @company_abbr, @billing_system, @service_package_id

end

go

