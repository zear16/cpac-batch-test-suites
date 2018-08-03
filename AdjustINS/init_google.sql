use PMDB

go

set nocount on

declare @company_id       unsigned bigint
declare @document_type_id unsigned bigint
declare @template_id      unsigned bigint
declare @package_name     varchar(200)
declare @package_code     unsigned bigint
declare @receipt_id       unsigned bigint
declare @run_date         char(8)
declare @version_id       unsigned bigint
declare @job_id           unsigned bigint
declare @job_chain        varchar(250)
declare @order_id         unsigned bigint
declare @template_code    varchar(200)

select @run_date = '20160615', @template_code = 'PE_DCB_REFUND_CWDC1'

select @job_id = JOB_ID, @job_chain = JOB_CHAIN from PM_JOB_SCHEDULER_MAPPING where TEMPLATE_CODE = @template_code

select @version_id = max(V.VERSION_ID) from
PM_FILE_CONFIG_VERSION V
inner join PM_FILE_CONFIG C on (C.FILE_CONFIG_ID = V.FILE_CONFIG_ID)
where C.TEMPLATE_CODE = @template_code

insert into PM_JOB_ORDER
(ORDER_TYPE, JOB_ID, TEMPLATE_CODE, ORDER_MODE, RUN_DATE, DATA_DATE_FR, DATA_DATE_TO,
VERSION_ID, FILE_NAME, ORIGINAL_FILE_NAME, FILE_PATH, ZIP_NAME, JOB_CHAIN, ORDER_STATUS)
values
("I", @job_id, @template_code, "A", @run_date, @run_date, @run_date,
@version_id, "Unit Test Adjust BOS", "Unit Test Adjust BOS", "/opt/ais/cpac/batchprepaid/package", "", @job_chain, "W")

select @order_id = @@identity

declare @batch_id unsigned bigint

insert into PM_PREPAID_LOAD_BATCH
(ORDER_ID, PROCESS_TYPE, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@order_id, 'I', 'unit', @run_date, 'unit', @run_date)

select @batch_id = @@identity

insert into PM_BATCH_DCB
(BATCH_ID, TRANSACTION_ID, MOBILE_NO, PARTIAL_FEE, END_CAUSE, SERVICE_PACKAGE_ID
, START_TIME, CATEGORY_ID, BANK_CODE
, RECORD_STATUS, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@batch_id, '201606161616160000', '0811097495', 938, '003', '5'
, '20160615', '300', 800
, 'SC', 'unit', '20160615', 'unit', '20160615')

insert into PM_BATCH_DCB
(BATCH_ID, TRANSACTION_ID, MOBILE_NO, PARTIAL_FEE, END_CAUSE, SERVICE_PACKAGE_ID
, START_TIME, CATEGORY_ID, BANK_CODE
, RECORD_STATUS, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@batch_id, '201606161616160001', '0811097495', 938, '003', '5'
, '20160615', '300', 800
, 'SC', 'unit', '20160615', 'unit', '20160615')

insert into PM_FILE_ADJUST
(ORDER_ID, FILE_NAME, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@order_id, 'Unit Test Adjust BOS reconcile with Google', 'unit', '20160615', 'unit', '20160615')

go

 
