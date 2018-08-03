use PMDB

go

set nocount on

declare @company_id unsigned bigint
declare @document_type_id unsigned bigint
declare @template_id unsigned bigint
declare @package_name varchar(200)
declare @package_code unsigned bigint
declare @receipt_id unsigned bigint

select @package_name = 'Unit Test ePin Normal Package Voice'

select @package_code = PACKAGE_CODE from PM_PACKAGE where PACKAGE_NAME = @package_name

delete PM_PACKAGE_BOS
from PM_PACKAGE_BOS P
where PRODUCT_ID = @package_code
--where PRODUCT_ID = 160000
and convert(date, OPERATION_DTM) = '20160615'

delete PM_RECEIPT
from PM_RECEIPT R
where R.RECEIPT_NO = 'Unit Test ePin Package Voice'
and R.RECEIPT_DATE = '20160615'

delete PM_PREPAID_LOAD_BATCH
from PM_PREPAID_LOAD_BATCH L
inner join PM_JOB_ORDER J on (L.ORDER_ID = J.ORDER_ID)
where J.RUN_DATE = '20160616'
and J.FILE_NAME = 'Unit Test ePin Package Voice'
and J.TEMPLATE_CODE = 'PE_Package_BOS'

delete PM_JOB_ORDER
from PM_JOB_ORDER J
where J.RUN_DATE = '20160616'
and J.FILE_NAME = 'Unit Test ePin Package Voice'
and J.TEMPLATE_CODE = 'PE_Package_BOS'

go

 
