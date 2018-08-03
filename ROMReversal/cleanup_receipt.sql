use PMDB

go

set nocount on

declare @backward int
declare @yy int
declare @mm int
declare @full_receipt_id unsigned bigint
declare @curr_date date
declare @receipt_id unsigned bigint
declare @receipt_date char(8)
declare @receipt_no char(22)

select @backward = convert(int,FIELD1_VALUE)
from PM_SYSTEM_ATTRIBUTE_DTL
where ATTRIBUTE_CODE = 'CPAC_PARAM'
and DB_VALUE = 'QUERY_RECHARGE_PERIOD'

select @yy = datepart(yy,dateadd(mm,-@backward,getdate()))
, @mm = datepart(mm,dateadd(mm,-@backward,getdate()))
, @curr_date = getdate()

select @receipt_date = convert(char(4),@yy) ||
right(replicate('0',2)+convert(varchar(2),@mm),2) || '01'

select @receipt_no = 'Z-PB-A-' || right(convert(char(4),@yy+543),2) ||
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


