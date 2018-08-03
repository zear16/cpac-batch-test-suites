use PMDB

go

create or replace procedure _CONVERT_POST_PRE_INSERT_RECEIPT (
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
  @period        char(4),
  @amount        decimal(14,2),
  @status        char(1),
  @location_code unsigned bigint,
  @ba_no         varchar(30),
  @mobile_no     varchar(20),
  @receipt_id    unsigned bigint out,
  @receipt_no    varchar(30)     out
) as

set nocount on

declare @ret_msg        varchar(250)
declare @receipt_dtl_id unsigned bigint
declare @excess_no      varchar(30)

exec PM_S_GEN_DOC_NO 'unit', @company_code, @bop_code, @doc_type, @channel_code, null, null
, @period, 1, @receipt_no out, @ret_msg out

insert into PM_RECEIPT
(RECEIPT_DATE, COMPANY_ID, DOCUMENT_TYPE_ID, TEMPLATE_ID, RECEIPT_NO
, MODE, RECEIPT_LOCATION_CODE, CHANNEL_ID, CATEGORY_CODE, BOP_ID
, RECEIPT_STATUS, STATUS_DTM, MODEL, RECEIPT_SENDING, FUTURE_RECEIPT_BOO
, USER_ID, VAT_CAL_BOO, NON_VAT_AMT, NET_VAT_AMT, VAT_AMT, VAT_RATE, TOTAL_AMT
, REFUND_NON_VAT_AMT, REFUND_NET_VAT_AMT, REFUND_VAT_AMT, REFUND_TOTAL_AMT
, NON_VAT_BAL, NET_VAT_BAL, VAT_BAL, TOTAL_BAL
, ALLOW_CANCEL_BOO, MOBILE_NO
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@trans_date, @company_id, @doc_type_id, 1, @receipt_no
, 'BA', @location_code, @channel_id, @category_code, @bop_id
, @status, @trans_date, 'OR', 'NO', 'N'
, 'unit', 'N', @amount, @amount, 0, 0, @amount
, 0, 0, 0, 0
, 0, 0, 0, @amount
, 'Y', @mobile_no
, 'unit', getdate(), 'unit', getdate())

select @receipt_id = @@identity

insert into PM_RECEIPT_ADDR
(RECEIPT_ID, RECEIPT_DATE, COM_ADDR1
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@receipt_id, @trans_date, 'ZZZ'
, 'unit', getdate(), 'unit', getdate())

insert into PM_RECEIPT_DTL
(RECEIPT_ID, RECEIPT_DATE, SUB_BOP_ID, ITEM_NO, NEGO_BOO
, DISCOUNT_AMT, NON_VAT_AMT, NET_VAT_AMT, VAT_RATE, VAT_AMT, TOTAL_AMT
, REFUND_NON_VAT_AMT, REFUND_NET_VAT_AMT, REFUND_VAT_AMT, REFUND_TOTAL_AMT
, NON_VAT_BAL, NET_VAT_BAL, VAT_BAL, TOTAL_BAL, ADJ_VAT_AMT
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@receipt_id, @trans_date, 1, 1, 'N'
, 0, @amount, @amount, 0, 0, @amount
, 0, 0, 0, @amount
, 0, 0, 0, @amount, 0
, 'unit', getdate(), 'unit', getdate())

select @receipt_dtl_id = @@identity

insert into PM_RECEIPT_PAYMENT
(RECEIPT_ID, RECEIPT_DATE, METHOD_CODE, REFUND_AMT, TOTAL_BAL, TOTAL_AMT, RECEIVE_WT_BOO
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@receipt_id, @trans_date, 2, 0, @amount, @amount, 'N'
, 'unit', getdate(), 'unit', getdate())

exec PM_S_GEN_DOC_NO 'unit', @company_code, 'E', 'X', @channel_code, null, null
, @period, 1, @excess_no out, @ret_msg out

insert into PM_EXCESS_BALANCE
(BA_NO, EXCESS_NO, COMPANY_ID, RECEIPT_DTL_ID, EXCESS_DATE
, EXCESS_NET_VAT_AMT, EXCESS_VAT_AMT, EXCESS_TOTAL_AMT, VAT_RATE
, EXCESS_NET_VAT_BAL, EXCESS_VAT_BAL, EXCESS_TOTAL_BAL
, CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
values
(@ba_no, @excess_no, @company_id, @receipt_dtl_id, @trans_date
, 0, 0, @amount, 0
, 0, 0, @amount
, 'unit', getdate(), 'unit', getdate())

go


