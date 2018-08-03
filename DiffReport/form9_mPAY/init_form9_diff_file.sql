use PMDB

go

declare cur cursor for
  select CS.BA_NO, CS.MOBILE_NO, C.COMPANY_ID, C.COMPANY_ABBR, CS.BILLING_SYSTEM
  from PM_V_CUST_PROFILE CS
  inner join PM_COMPANY C on (CS.INVOICING_COMPANY = C.COMPANY_ABBR)
  where CS.MOBILE_NO in ('0817066135','0854059610','0810055482','0818038764','0854067640','0802022691','0901071692','0854037358','0801042496','0901035186')
  and CS.CHARGE_TYPE = 'Pre-paid'

go

declare @mobile_no          varchar(20)
declare @batch_id           unsigned bigint
declare @bank_code          unsigned bigint
declare @payment_date       datetime
declare @total_amt          decimal(14,2)
declare @company_abbr       varchar(5)
declare @company_id         unsigned bigint
declare @ba_no              varchar(30)
declare @billing_system     varchar(5)
declare @sequence_no        int

select @total_amt = 41

select @batch_id = L.BATCH_ID
     , @payment_date = O.DATA_DATE_FR
from PM_PREPAID_LOAD_BATCH L
inner join PM_JOB_ORDER O on (L.ORDER_ID = O.ORDER_ID)
where O.TEMPLATE_CODE = 'PE_MPAY_REVERSAL'
and O.DATA_DATE_FR = '20170120'

select @sequence_no = max(convert(int, SEQUENCE_NO))
from PM_BATCH_RVS
where BATCH_ID = @batch_id

select @sequence_no = @sequence_no + 1

-- clean up
delete from PM_BATCH_RVS
where BATCH_ID = @batch_id
and CREATED_BY = 'SUYADA'
and TOPUP_MOBILE_NO in ('0817066135','0854059610','0810055482','0818038764','0854067640','0802022691','0901071692','0854037358','0801042496','0901035186')
and BANK_CODE = 500

print 'delete PM_BATCH_RVS %1! records', @@rowcount
---------



open cur

fetch next cur into @ba_no, @mobile_no, @company_id, @company_abbr, @billing_system

while (@@sqlstatus = 0)
begin
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
    @batch_id, convert(varchar(6), @sequence_no), 500, @company_id
    , @payment_date, '20:00:00', @mobile_no
    , newid(), 'RVS'
    , @total_amt, @total_amt
    , 'batchrvs000000' || convert(varchar(10), @sequence_no), '3G'
    , @billing_system
    , 'SUYADA', getdate(), 'SUYADA', getdate()
  )

  fetch next cur into @ba_no, @mobile_no, @company_id, @company_abbr, @billing_system

end

go

