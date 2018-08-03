use PMDB

go

set nocount on

declare @job_id                    unsigned bigint
declare @version_id                unsigned bigint
declare @sync_name                 varchar(200)
declare @order_id                  unsigned bigint
declare @run_date                  char(8)
declare @template_code             varchar(250)

declare @trans_no                  unsigned bigint
declare @wrong_number_sub_cause_id unsigned bigint
declare @wrong_mobile_no           varchar(20)
declare @topup_mobile_no           varchar(20)
declare @wrong_ba_no               varchar(32)
declare @topup_ba_no               varchar(32)
declare @adjust_id                 unsigned bigint

declare @ret_msg                   varchar(250)
declare @ret_code                  int

-- Init Adjust Transaction 

select @trans_no = 0
, @run_date = '20161221'
, @template_code = 'PE_GEN_ADJUST_CREDIT_NOTE'
, @wrong_mobile_no = '0817066135', @wrong_ba_no = '201607210066135'
, @topup_mobile_no = '0901081137', @topup_ba_no = '201607210081137'

select @wrong_number_sub_cause_id = C.SUB_CAUSE_ID
from PM_SYSTEM_ATTRIBUTE_DTL A
inner join PM_SUB_CAUSE C on (A.FIELD1_VALUE = C.SUB_CAUSE_CODE)
where A.ATTRIBUTE_CODE = 'CPAC_PARAM'
and A.DB_VALUE = 'WRONG_NUMBER_SUB_CAUSE'

insert into PM_ADJUST_TRANSACTION
(TRANS_NO, MOBILE_NO, REF_MOBILE_NO, ACCOUNT_NO, COMPANY_ID
, BANK_CODE, SERVICE_ID, COST_CENTER_ID, SUB_CAUSE_ID, LOCATION_CODE
, ADJUST_AMT, ADJUST_VALIDITY, ADJUST_DTM, ADJUST_DATE, GEN_CN_BOO
, REMARK, ADJUST_STATUS, BILLING_SYSTEM
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@trans_no, @wrong_mobile_no, null, @wrong_ba_no, 6
, 2, 1, null, @wrong_number_sub_cause_id, 1020
, 100, 0,  dateadd(dd, -1, @run_date),  dateadd(dd, -1, @run_date), 'Y'
, null, 'SC', 'BOS'
, 'SUYADA', getdate(), 'SUYADA', getdate()
)

select @adjust_id = @@identity

insert into PM_ADJUST_TRANSACTION
(TRANS_NO, MOBILE_NO, REF_MOBILE_NO, ACCOUNT_NO, COMPANY_ID
, BANK_CODE, SERVICE_ID, COST_CENTER_ID, SUB_CAUSE_ID, LOCATION_CODE
, ADJUST_AMT, ADJUST_VALIDITY, ADJUST_DTM, ADJUST_DATE, GEN_CN_BOO
, REMARK, ADJUST_STATUS, BILLING_SYSTEM
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@trans_no, @topup_mobile_no, @wrong_mobile_no, @topup_ba_no, 6
, 2, 1, null, @wrong_number_sub_cause_id, 1020
, 100, 0,  dateadd(dd, -1, @run_date),  dateadd(dd, -1, @run_date), 'N'
, null, 'SC', 'BOS'
, 'SUYADA', getdate(), 'SUYADA', getdate()
)

/*
-- Create Job Order
select @order_id = ORDER_ID from PM_JOB_ORDER
where TEMPLATE_CODE = @template_code
if (@@rowcount = 0)
begin

  insert into PM_JOB_ORDER
  (ORDER_TYPE, JOB_ID, TEMPLATE_CODE, ORDER_MODE, RUN_DATE, DATA_DATE_FR, DATA_DATE_TO
  , ORDER_STATUS)
  values
  ('I', @job_id, @template_code, 'A', @run_date, dateadd(dd, -1, @run_date), dateadd(dd, -1, @run_date)
  , 'W')

  select @order_id = @@identity

end

-- process generate credit note
execute @ret_code = PM_S_TX_BATCH_CREDIT_NOTE_FROM_ADJUST @order_id, @ret_msg out
*/

print '%1!', @adjust_id

go

