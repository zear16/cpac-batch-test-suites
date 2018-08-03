use PMDB

go

declare cur cursor for
  select CS.BA_NO, CS.MOBILE_NO, convert(decimal(5,2), left(CS.CUS_VAT_RATE,1)), C.COMPANY_ID, C.COMPANY_CODE, CS.BILLING_SYSTEM
  from PM_V_CUST_PROFILE CS
  inner join PM_COMPANY C on (CS.INVOICING_COMPANY = C.COMPANY_ABBR)
  where CS.MOBILE_NO in ('0854050028', '0810076836', '0854065167', '0854074673', '0810027579', '0819088499', '0811088522', '0811050275', '0818062905', '0810026367', '0901022935', '0802031676', '0819061634', '0854061031', '0800097869', '0819011486', '0817057147', '0819043982', '0901071169')
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

declare @i                int
declare @r                int

select @batch_id = L.BATCH_ID, @recharge_date = O.DATA_DATE_FR
from PM_JOB_ORDER O
inner join PM_PREPAID_LOAD_BATCH L on (O.ORDER_ID = L.ORDER_ID)
where TEMPLATE_CODE = 'PE_RECHARGE_RECONCILE'
and RUN_DATE = '20170125'

select @service_id = 40
     , @location_code = 1020
     , @total_amt = 201
     , @i = 0


-- clean up

delete from PM_RECHARGE
where RECHARGE_DATE = @recharge_date
and RECHARGE_CHANNEL in (39, 63, 47)
and CREATED_BY = 'SUYADA'
and MOBILE_NO in ('0854050028', '0810076836', '0854065167', '0854074673', '0810027579', '0819088499', '0811088522', '0811050275', '0818062905', '0810026367', '0901022935', '0802031676', '0819061634', '0854061031', '0800097869', '0819011486', '0817057147', '0819043982', '0901071169')

print 'delete PM_RECHARGE %1! records', @@rowcount

----

open cur
fetch next cur into @ba_no, @mobile_no, @vat_rate, @company_id, @company_code, @billing_system

while (@@sqlstatus = 0)
begin

  select @i = @i + 1
  select @r = @i%3
  if (@r = 0)
  begin
    select @service_id = 36
  end
  if (@r = 1)
  begin
    select @service_id = 63
  end
  if (@r = 2)
  begin
    select @service_id = 47
  end

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
  , BILLING_SYSTEM, RECORD_STATUS 
  , SPECIFICATION_ID
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD
  )
  values(
    null, newid(), 'N'
  , @company_id, 'Pre-paid', @recharge_date
  , @mobile_no, @ba_no
  , 'Y', 14
  , @total_amt, @recharge_date
  , @service_id, null
  , null, null, null
  , 'N', null, null, null
  , null, null, null
  , null, null, 'N'
  , @billing_system, 'SC'
  , 90001
  , 'SUYADA', getdate(), 'SUYADA', getdate()
  )

  print 'Insert PM_RECHARGE RECHARGE_ID = %1!', @@identity

  fetch next cur into @ba_no, @mobile_no, @vat_rate, @company_id, @company_code, @billing_system

end


go

