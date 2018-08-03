use PMDB

go

set nocount on

go

create or replace procedure _INSERT_RECEIPT (
  @trans_date    date,
  @company_id    unsigned bigint,
  @company_code  char(1),
  @bop_id        unsigned bigint,
  @bop_code      char(1),
  @doc_type_id   unsigned bigint,
  @doc_type      char(1),
  @channel_id    unsigned bigint,
  @channel_code  char(1),
  @category_code unsigned bigint,
  @bank_code     unsigned bigint,
  @period        char(4),
  @amount        decimal(14,2),
  @status        char(1),
  @location_code unsigned bigint,
  @mobile_no     varchar(20),
  @service_id    unsigned bigint,
  @batch_no      varchar(10),
  @serial_no     varchar(10),
  @scratch_no    varchar(20),
  @receipt_id    unsigned bigint out,
  @receipt_no    varchar(30)     out
) as

set nocount on

declare @ret_msg        varchar(250)
declare @receipt_dtl_id unsigned bigint
declare @sub_bop_id     unsigned bigint

select @sub_bop_id = SUB_BOP_ID from PM_SUB_BUSINESS_OF_PAYMENT where SUB_BOP_CODE = 'PT'

exec PM_S_GEN_DOC_NO 'unit', @company_code, @bop_code, @doc_type, @channel_code, null, null
, @period, 1, @receipt_no out, @ret_msg out

insert into PM_RECEIPT
(RECEIPT_DATE, COMPANY_ID, DOCUMENT_TYPE_ID, TEMPLATE_ID, RECEIPT_NO
, MODE, RECEIPT_LOCATION_CODE, CHANNEL_ID, CATEGORY_CODE, BOP_ID, BANK_CODE
, RECEIPT_STATUS, STATUS_DTM, MODEL, RECEIPT_SENDING, FUTURE_RECEIPT_BOO
, USER_ID, VAT_CAL_BOO, NON_VAT_AMT, NET_VAT_AMT, VAT_AMT, VAT_RATE, TOTAL_AMT
, REFUND_NON_VAT_AMT, REFUND_NET_VAT_AMT, REFUND_VAT_AMT, REFUND_TOTAL_AMT
, NON_VAT_BAL, NET_VAT_BAL, VAT_BAL, TOTAL_BAL
, ALLOW_CANCEL_BOO, MOBILE_NO
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@trans_date, @company_id, @doc_type_id, 1, @receipt_no
, 'BA', @location_code, @channel_id, @category_code, @bop_id, @bank_code
, @status, @trans_date, 'OR', 'NO', 'N'
, 'unit', 'N', @amount, @amount, 0, 0, @amount
, 0, 0, 0, 0
, 0, 0, 0, @amount
, 'Y', @mobile_no
, 'unit', getdate(), 'unit', getdate())

select @receipt_id = @@identity

insert into PM_RECEIPT_DTL
(RECEIPT_ID, RECEIPT_DATE, SUB_BOP_ID, ITEM_NO, NEGO_BOO
, DISCOUNT_AMT, NON_VAT_AMT, NET_VAT_AMT, VAT_RATE, VAT_AMT, TOTAL_AMT
, MOBILE_NO
, REFUND_NON_VAT_AMT, REFUND_NET_VAT_AMT, REFUND_VAT_AMT, REFUND_TOTAL_AMT
, NON_VAT_BAL, NET_VAT_BAL, VAT_BAL, TOTAL_BAL, ADJ_VAT_AMT
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@receipt_id, @trans_date, @sub_bop_id, 1, 'N'
, 0, @amount, @amount, 0, 0, @amount
, @mobile_no
, 0, 0, 0, @amount
, 0, 0, 0, @amount, 0
, 'unit', getdate(), 'unit', getdate())

select @receipt_dtl_id = @@identity

insert into PM_RECEIPT_PREPAID
(RECEIPT_ID, RECEIPT_DATE, SERVICE_ID
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@receipt_id, @trans_date, @service_id
, 'unit', getdate(), 'unit', getdate())

insert into PM_RECEIPT_DTL_PREPAID
(RECEIPT_DTL_ID, RECEIPT_DATE, PREPAID_BATCH_NO, PREPAID_SERIAL_NO, SCRATCH_CARD_NO
, DEDUCT_BOO
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@receipt_dtl_id, @trans_date, @batch_no, @serial_no, @scratch_no
, 'N'
, 'unit', getdate(), 'unit', getdate())

go

declare @bank_code     unsigned bigint
declare @trans_date    date
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
declare @mobile_no      varchar(20)

select @trans_date = '20160616'
, @mobile_no = '0901033119'
, @company_code = 'W'
, @bop_code = 'I'
, @channel_code = 'B'
, @doc_type = 'B'

select @bank_code = BANK_CODE from PM_BANK where BANK_ABBR = 'GGP'

select @company_id = COMPANY_ID
from PM_COMPANY where COMPANY_CODE = @company_code

select @channel_id = CHANNEL_ID
from PM_PAYMENT_CHANNEL where CHANNEL_CODE = @channel_code

select @category_code = CATEGORY_CODE
from PM_PAYMENT_CATEGORY where CATEGORY_ABBR = 'MP'

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

-- Test Case reconcile_gen_diff
exec _INSERT_RECEIPT @trans_date, @company_id, @company_code, @bop_id, @bop_code
, @doc_type_id, @doc_type, @channel_id, @channel_code, @category_code, null
, @period, 7016, 'N', @location_code, @mobile_no
, 46, null, null, null
, @receipt_id out, @doc_no out

go

drop procedure _INSERT_RECEIPT

go

