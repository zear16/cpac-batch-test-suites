use PMDB

go

set nocount on

go


declare curs cursor
for select ORDER_ID from PM_JOB_ORDER
where TEMPLATE_CODE = 'CONVERT_POST_TO_PRE'
and RUN_DATE = '20160616'

go

declare @order_id      unsigned bigint
declare @run_date date

select @run_date = '20160616'

open curs
fetch curs into @order_id
while (@@sqlstatus = 0)
begin
  delete PM_BATCH_CONVERT_POST_PRE_SEND_ORDER
  from PM_JOB_ORDER O
  inner join PM_PREPAID_LOAD_BATCH B on (O.ORDER_ID = B.ORDER_ID)
  inner join PM_BATCH_CONVERT_POST_PRE C on (B.BATCH_ID = C.BATCH_ID)
  inner join PM_BATCH_CONVERT_POST_PRE_SEND_ORDER S on (C.BATCH_ID = S.BATCH_ID)
  where O.ORDER_ID = @order_id

  delete from PM_CREDIT_NOTE
  from PM_JOB_ORDER O
  inner join PM_PREPAID_LOAD_BATCH B on (O.ORDER_ID = B.ORDER_ID)
  inner join PM_BATCH_CONVERT_POST_PRE C on (B.BATCH_ID = C.BATCH_ID)
  inner join PM_CREDIT_NOTE CN on (C.CN_ID = CN.CN_ID)
  where O.ORDER_ID = @order_id
  and CN.CN_DATE = @run_date

  delete from PM_CREDIT_NOTE_DTL
  from PM_JOB_ORDER O
  inner join PM_PREPAID_LOAD_BATCH B on (O.ORDER_ID = B.ORDER_ID)
  inner join PM_BATCH_CONVERT_POST_PRE C on (B.BATCH_ID = C.BATCH_ID)
  inner join PM_CREDIT_NOTE CN on (C.CN_ID = CN.CN_ID)
  inner join PM_CREDIT_NOTE_DTL D on (CN.CN_ID = D.CN_ID and CN.CN_DATE = D.CN_DATE)
  where O.ORDER_ID = @order_id
  and CN.CN_DATE = @run_date

  delete from PM_RECEIPT
  from PM_JOB_ORDER O
  inner join PM_PREPAID_LOAD_BATCH B on (O.ORDER_ID = B.ORDER_ID)
  inner join PM_BATCH_CONVERT_POST_PRE C on (B.BATCH_ID = C.BATCH_ID)
  inner join PM_RECEIPT R on (C.RECEIPT_ID = R.RECEIPT_ID)
  where O.ORDER_ID = @order_id
  and R.RECEIPT_DATE = @run_date

  delete from PM_RECEIPT_DTL
  from PM_JOB_ORDER O
  inner join PM_PREPAID_LOAD_BATCH B on (O.ORDER_ID = B.ORDER_ID)
  inner join PM_BATCH_CONVERT_POST_PRE C on (B.BATCH_ID = C.BATCH_ID)
  inner join PM_RECEIPT R on (C.RECEIPT_ID = R.RECEIPT_ID)
  inner join PM_RECEIPT_DTL D on (R.RECEIPT_ID = D.RECEIPT_ID and R.RECEIPT_DATE = D.RECEIPT_DATE)
  where O.ORDER_ID = @order_id
  and R.RECEIPT_DATE = @run_date

  delete from PM_RECEIPT_PAYMENT
  from PM_JOB_ORDER O
  inner join PM_PREPAID_LOAD_BATCH B on (O.ORDER_ID = B.ORDER_ID)
  inner join PM_BATCH_CONVERT_POST_PRE C on (B.BATCH_ID = C.BATCH_ID)
  inner join PM_RECEIPT R on (C.RECEIPT_ID = R.RECEIPT_ID)
  inner join PM_RECEIPT_PAYMENT P on (R.RECEIPT_ID = P.RECEIPT_ID and R.RECEIPT_DATE = P.RECEIPT_DATE)
  where O.ORDER_ID = @order_id
  and R.RECEIPT_DATE = @run_date

  delete from PM_INF_PLUGIN_PREPAID_CN_EXCESS
  from PM_JOB_ORDER O
  inner join PM_INF_PLUGIN_PREPAID_CN_EXCESS I on (O.ORDER_ID = I.ORDER_ID)
  where O.TEMPLATE_CODE = 'EXP_PLUGIN_PREPAID_CN_EXCESS'
  and O.REF_ORDER_ID = @order_id

  delete from PM_JOB_ORDER
  where TEMPLATE_CODE = 'EXP_PLUGIN_PREPAID_CN_EXCESS'
  and REF_ORDER_ID = @order_id

  delete from PM_INF_BSS_TOPUP_T
  from PM_JOB_ORDER O
  inner join PM_INF_BSS_TOPUP_T T on (O.ORDER_ID = T.ORDER_ID)
  where O.TEMPLATE_CODE = 'EXP_BSS_TOPUP'
  and O.REF_ORDER_ID = @order_id

  delete from PM_INF_BSS_TOPUP_D
  from PM_JOB_ORDER O
  inner join PM_INF_BSS_TOPUP_D D on (O.ORDER_ID = D.ORDER_ID)
  where O.TEMPLATE_CODE = 'EXP_BSS_TOPUP'
  and O.REF_ORDER_ID = @order_id

  delete from PM_INF_BSS_TOPUP_H
  from PM_JOB_ORDER O
  inner join PM_INF_BSS_TOPUP_H H on (O.ORDER_ID = H.ORDER_ID)
  where O.TEMPLATE_CODE = 'EXP_BSS_TOPUP'
  and O.REF_ORDER_ID = @order_id

  delete from PM_JOB_ORDER
  where TEMPLATE_CODE = 'EXP_BSS_TOPUP'
  and REF_ORDER_ID = @order_id

  delete PM_TOPUP_TRANSACTION
  from PM_JOB_ORDER O
  inner join PM_PREPAID_LOAD_BATCH B on (O.ORDER_ID = B.ORDER_ID)
  inner join PM_BATCH_CONVERT_POST_PRE C on (B.BATCH_ID = C.BATCH_ID)
  inner join PM_TOPUP_TRANSACTION T on (C.TOPUP_ID = T.TOPUP_ID)
  where O.ORDER_ID = @order_id

  delete PM_BATCH_CONVERT_POST_PRE
  from PM_JOB_ORDER O
  inner join PM_PREPAID_LOAD_BATCH B on (O.ORDER_ID = B.ORDER_ID)
  inner join PM_BATCH_CONVERT_POST_PRE C on (B.BATCH_ID = C.BATCH_ID)
  where O.ORDER_ID = @order_id

  delete PM_PREPAID_LOAD_BATCH
  from PM_JOB_ORDER O
  inner join PM_PREPAID_LOAD_BATCH B on (O.ORDER_ID = B.ORDER_ID)
  where O.ORDER_ID = @order_id

  delete from PM_JOB_ORDER where ORDER_ID = @order_id

  fetch curs into @order_id
end

go


