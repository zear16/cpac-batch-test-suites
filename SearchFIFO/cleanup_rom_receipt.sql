use PMDB

go

set nocount on

declare @backward        int
declare @yy              int
declare @mm              int
declare @full_receipt_id unsigned bigint
declare @payment_date    date
declare @curr_date       date
declare @receipt_id      unsigned bigint
declare @receipt_date    date
declare @receipt_no      char(22)
declare @channel_id      unsigned bigint
declare @sub_bop_id      unsigned bigint

select @payment_date = '20160616'

-- ROM
select @channel_id = CHANNEL_ID
from PM_PAYMENT_CHANNEL
where CHANNEL_CODE = 'O'

-- Top Up
select @sub_bop_id = SUB_BOP_ID
from PM_SUB_BUSINESS_OF_PAYMENT
where SUB_BOP_CODE = 'PT'

select @backward = PERIOD
from PM_CFG_REVERSAL_PERIOD
where CHANNEL_ID = @channel_id
and SUB_BOP_ID = @sub_bop_id

select @receipt_date = dateadd(dd, 1 - @backward, @payment_date)

select @yy = datepart(yy,@receipt_date)
, @mm = datepart(mm,@receipt_date)

select @receipt_no = 'Z-PR-A-' || right(convert(char(4),@yy+543),2) ||
right(replicate('0',2)+convert(varchar(2),@mm),2) || '-0000000016'

print '@receipt_no=[%1!],@receipt_date=[%2!]', @receipt_no, @receipt_date

select @receipt_id = RECEIPT_ID
from PM_RECEIPT
where RECEIPT_NO = @receipt_no
and RECEIPT_DATE = @receipt_date
if (@@rowcount != 0)
begin

  select @full_receipt_id = RECEIPT_ID
  from PM_RECEIPT
  where REF_RECEIPT_ID = @receipt_id
  and RECEIPT_DATE = @receipt_date
  if (@@rowcount = 0)
  begin
    select @full_receipt_id = @receipt_id
  end

  delete PM_CREDIT_NOTE_DTL
  from PM_CREDIT_NOTE_MAP M
  inner join PM_CREDIT_NOTE C on (M.CN_ID = C.CN_ID)
  inner join PM_CREDIT_NOTE_DTL P on (C.CN_ID = P.CN_ID)
  where M.RECEIPT_ID = @full_receipt_id
  and M.RECEIPT_DATE = @receipt_date
  and M.CN_DATE = @curr_date
  and C.CN_DATE = @curr_date
  and P.CN_DATE = @curr_date

  delete PM_CREDIT_NOTE_ADDR
  from PM_CREDIT_NOTE_MAP M
  inner join PM_CREDIT_NOTE C on (M.CN_ID = C.CN_ID)
  inner join PM_CREDIT_NOTE_ADDR P on (C.CN_ID = P.CN_ID)
  where M.RECEIPT_ID = @full_receipt_id
  and M.RECEIPT_DATE = @receipt_date
  and M.CN_DATE = @curr_date
  and C.CN_DATE = @curr_date
  and P.CN_DATE = @curr_date

  delete PM_CREDIT_NOTE_PAYMENT
  from PM_CREDIT_NOTE_MAP M
  inner join PM_CREDIT_NOTE C on (M.CN_ID = C.CN_ID)
  inner join PM_CREDIT_NOTE_PAYMENT P on (C.CN_ID = P.CN_ID)
  where M.RECEIPT_ID = @full_receipt_id
  and M.RECEIPT_DATE = @receipt_date
  and M.CN_DATE = @curr_date
  and C.CN_DATE = @curr_date
  and P.CN_DATE = @curr_date

  delete PM_CREDIT_NOTE
  from PM_CREDIT_NOTE_MAP M
  inner join PM_CREDIT_NOTE C on (M.CN_ID = C.CN_ID)
  where M.RECEIPT_ID = @full_receipt_id
  and M.RECEIPT_DATE = @receipt_date
  and M.CN_DATE = @curr_date
  and C.CN_DATE = @curr_date

  delete PM_CREDIT_NOTE_MAP
  from PM_CREDIT_NOTE_MAP M
  inner join PM_CREDIT_NOTE C on (M.CN_ID = C.CN_ID)
  where M.RECEIPT_ID = @full_receipt_id
  and M.RECEIPT_DATE = @receipt_date
  and M.CN_DATE = @curr_date
  and C.CN_DATE = @curr_date

  delete PM_RECEIPT_PAYMENT
  from PM_RECEIPT R
  inner join PM_RECEIPT_PAYMENT P on (R.RECEIPT_ID = P.RECEIPT_ID)
  where R.RECEIPT_ID in (@full_receipt_id, @receipt_id)
  and R.RECEIPT_DATE = @receipt_date
  and P.RECEIPT_DATE = @receipt_date

  delete PM_RECEIPT_DTL
  from PM_RECEIPT R
  inner join PM_RECEIPT_DTL P on (R.RECEIPT_ID = P.RECEIPT_ID)
  where R.RECEIPT_ID in (@full_receipt_id, @receipt_id)
  and R.RECEIPT_DATE = @receipt_date
  and P.RECEIPT_DATE = @receipt_date

  delete from PM_RECEIPT
  where RECEIPT_ID in (@full_receipt_id, @receipt_id)
  and RECEIPT_DATE = @receipt_date

end

go


