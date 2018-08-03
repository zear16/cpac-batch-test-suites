use PMDB

go

set nocount on

declare @template_code varchar(200)
declare @run_date      date
declare @order_id      unsigned bigint

select @template_code = 'PE_MPAY_CASH_CARD_EXP'
, @run_date = '20160616'

select @order_id = ORDER_ID
from PM_JOB_ORDER
where TEMPLATE_CODE = @template_code
and RUN_DATE = @run_date
if (@@rowcount = 0)
begin

  insert into PM_JOB_ORDER
  (ORDER_TYPE, TEMPLATE_CODE, ORDER_MODE, RUN_DATE
  , ORIGINAL_FILE_NAME
  , FILE_NAME
  , FILE_PATH
  , SOURCE_CTRL_NAME
  , SOURCE_CTRL_PATH
  , DATA_DATE_FR, DATA_DATE_TO, ORDER_STATUS)
  select 'E', @template_code, 'A', @run_date
  , 'AMP_RECHARGE_MERCHANTID_' || convert(char(8),@run_date,112) || '_1.dat'
  , 'AMP_RECHARGE_MERCHANTID_' || convert(char(8),@run_date,112) || '_1.dat'
  , '/export/home/MNT_NFS/cpac/payment/dev/batch/mpay_settlement/cashcard'
  , 'AMP_RECHARGE_MERCHANTID_' || convert(char(8),@run_date,112) || '_1.end'
  , '/export/home/MNT_NFS/cpac/payment/dev/batch/mpay_settlement/cashcard'
  , dateadd(dd, -2, @run_date), dateadd(dd, -2, @run_date), 'W'

  select @order_id = @@identity

end
else
begin

  update PM_JOB_ORDER set ORDER_STATUS = 'W'
  where ORDER_ID = @order_id

end

delete PM_CASH_CARD_RECEIPT
from PM_RECHARGE R
inner join PM_CASH_CARD_RECEIPT CR on (R.CARD_BATCH_ID = CR.CARD_BATCH_ID
and R.CARD_SERIAL_NO = CR.CARD_SERIAL_NO)
where R.RECHARGE_DATE = dateadd(dd, -2, @run_date)
and R.DCC_E_TOPUP_SESSION_ID = '16161616161616161616@CC'
and R.MOBILE_NO = '0901000009'

print '%1!', @order_id

go

