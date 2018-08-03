use PMDB

go

declare @run_date date
declare @order_id unsigned bigint
declare @criteria varchar(250)
declare @batch_id varchar(20)

select @batch_id = convert(varchar(20), L.BATCH_ID)
from PM_JOB_ORDER O
inner join PM_PREPAID_LOAD_BATCH L on (O.ORDER_ID = L.ORDER_ID)
where O.TEMPLATE_CODE = 'PE_PARTNER_TOPUP'
and O.RUN_DATE = '20170123'
and O.ORDER_TYPE = 'I'


select @run_date = convert(date, getdate())
, @criteria = '{"batchId":' || '"' || @batch_id || '"}'

insert into PM_JOB_ORDER(
ORDER_TYPE, TEMPLATE_CODE, JOB_CHAIN, ORDER_MODE
, RUN_DATE, DATA_DATE_FR, DATA_DATE_TO
, ORDER_STATUS, ORDER_STATUS_DT
, USER_NAME
)
values(
'R', 'REPORT', '/payment/report/job_chain', 'M'
, @run_date, @run_date, @run_date
, 'W', getdate()
, 'SUYADA'
)

select @order_id = @@identity

insert into PM_REPORT_ORDER(
REPORT_CODE, ORDER_ID, FILE_TYPE, ORDER_TYPE
, RUN_DTM, STATUS
--, FILE_PATH
--, FILE_NAME
, CRITERIA
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD
)
values('PMRRP416', @order_id, 'EXCEL', 'L'
, getdate(), 'W'
--, '\opt\ais\cpac\payment\report\batch'
--, 'PMRRP402_TestRPT_' || convert(varchar(10), getdate(), 112) || convert(varchar(12), getdate(), 20)  || '.xlsx'
, @criteria
, 'SUYADA', getdate(), 'SUYADA', getdate()
)

print '@order_id = %1!', @order_id

go

