use PMDB

go

set nocount on

declare @data_date      date
declare @receipt_id     unsigned bigint
declare @receipt_dtl_id unsigned bigint

select @data_date = '20160616'

while (1 = 1)
begin

  select @receipt_id = R.RECEIPT_ID, @receipt_dtl_id = RD.RECEIPT_DTL_ID
  from PM_RECEIPT_DTL RD
  inner join PM_RECEIPT R on (RD.RECEIPT_ID = R.RECEIPT_ID and RD.RECEIPT_DATE = R.RECEIPT_DATE)
  inner join PM_PAYMENT_CATEGORY CT on (R.CATEGORY_CODE = CT.CATEGORY_CODE)
  inner join PM_BUSINESS_OF_PAYMENT BOP on (R.BOP_ID = BOP.BOP_ID)
  where RD.RECEIPT_DATE = @data_date
  and CT.CATEGORY_ABBR = 'PP'
  and BOP.BOP_CODE = 'P'
  if (@@rowcount = 0)
  begin
    break
  end

  delete from PM_RECEIPT_DTL where RECEIPT_ID = @receipt_id and RECEIPT_DATE = @data_date
  delete from PM_RECEIPT where RECEIPT_ID = @receipt_id and RECEIPT_DATE = @data_date

end

go

