use PMDB

go

set nocount on

go

declare curs cursor
for select top 1 BA.ROW_ID, BA.ACCNT_NO, AI.MOBILE_NO
from CPDB..SFF_ACCOUNT BA
inner join CPDB..SFF_ASSET_INSTANCE AI on (BA.ROW_ID = AI.BILLING_ACCNT_ID and AI.CHARGE_TYPE = 'Pre-paid')
inner join CPDB..SFF_ASSET_INSTANCE PI on (BA.ROW_ID = PI.BILLING_ACCNT_ID and PI.CHARGE_TYPE = 'Post-paid')
where BA.ACCNT_CLASS = 'Billing'
and BA.BILLING_SYSTEM = 'RTBS'
and BA.ACCNT_NO like '2016072%'
and AI.MOBILE_NO = '0892500003'

go

declare @trans_date     date
declare @post_accnt_id  varchar(50)
declare @ba_no          varchar(50)
declare @mobile_no      varchar(20)
declare @i              int
declare @status_code    varchar(30)
declare @channel_id     unsigned bigint
declare @company_id     unsigned bigint
declare @category_code  unsigned bigint
declare @method_code    unsigned bigint
declare @doc_no         varchar(22)
declare @receipt_id     unsigned bigint
declare @cn_id          unsigned bigint
declare @company_code   char(1)
declare @bop_id         unsigned bigint
declare @bop_code       char(1)
declare @channel_code   char(1)
declare @doc_type       char(1)
declare @doc_type_id    unsigned bigint
declare @location_code  unsigned bigint
declare @period         char(4)
declare @ret_msg        varchar(250)
declare @order_id       varchar(50)

select @trans_date = dateadd(dd, -1, '20160616')
, @status_code = 'S'
, @company_code = 'Z'
, @bop_code = 'I'
, @channel_code = 'B'
, @doc_type = 'B'

select @period = right('00' || convert(varchar(4),datepart(yy,@trans_date)+543),2)
|| right('00' || convert(varchar(2),datepart(mm,@trans_date)),2)

select @company_id = COMPANY_ID
from PM_COMPANY where COMPANY_CODE = @company_code

select @channel_id = CHANNEL_ID
from PM_PAYMENT_CHANNEL where CHANNEL_CODE = @channel_code

select @category_code = CATEGORY_CODE
from PM_PAYMENT_CATEGORY where CATEGORY_ABBR = 'CB'

select @method_code = METHOD_CODE
from PM_PAYMENT_METHOD where METHOD_ABBR = 'CA'

select @doc_type_id = DOCUMENT_TYPE_ID
from PM_DOCUMENT_TYPE where DOCUMENT_TYPE = @doc_type

select @bop_id = BOP_ID
from PM_BUSINESS_OF_PAYMENT where BOP_CODE = @bop_code

select @location_code = M.LOCATION_CODE
from PM_RECHARGE_SERVICE S
inner join PM_RECHARGE_SERVICE_MAPPING M on (S.SERVICE_ROW_ID = M.SERVICE_ROW_ID)
where S.SERVICE_ID = 52

open curs
fetch curs into @post_accnt_id, @ba_no, @mobile_no
while (@@sqlstatus = 0)
begin

  select @order_id = newid()

  insert into CPDB..SFF_ORDER
  (ROW_ID, ORDER_TYPE, STATUS_CD, STATUS_DT, COMPLETED_DT
  , MODIFICATION_NUM, REQUEST_ID, WO_ID, SUBCONTRACTOR
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@order_id, 'Convert Postpaid to Prepaid', 'Completed', @trans_date, @trans_date
  , 0, 0, 0, ''
  , 'unit', getdate(), 'unit', getdate())

  insert into CPDB..SFF_ORDER_SERVICE_INSTANCE
  (ROW_ID, ORDER_ID, BILLING_ACCNT_ID, NEW_BILLING_ACCNT_ID
  , MOBILE_NO, MODIFICATION_NUM, BUNDLING_FLG
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (newid(), @order_id, @post_accnt_id, @post_accnt_id
  , @mobile_no, 0, 'N'
  , 'unit', getdate(), 'unit', getdate())

  exec _CONVERT_POST_PRE_INSERT_RECEIPT @trans_date, @company_id, @company_code, @bop_id, @bop_code
  , @doc_type_id, @doc_type, @channel_id, @channel_code, @category_code
  , @period, 16, 'N', @location_code, @ba_no, @mobile_no, @receipt_id out, @doc_no out

  fetch curs into @post_accnt_id, @ba_no, @mobile_no
end

close curs
deallocate cursor curs

go


