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
  inner join PM_RECEIPT_DTL_PREPAID RDP on (RD.RECEIPT_DTL_ID = RDP.RECEIPT_DTL_ID and RD.RECEIPT_DATE = RDP.RECEIPT_DATE)
  inner join PM_RECEIPT R on (RD.RECEIPT_ID = R.RECEIPT_ID and RD.RECEIPT_DATE = R.RECEIPT_DATE)
  inner join PM_RECEIPT_PREPAID RP on (R.RECEIPT_ID = RP.RECEIPT_ID and R.RECEIPT_DATE = RP.RECEIPT_DATE)
  inner join PM_SUB_BUSINESS_OF_PAYMENT BOP on (RD.SUB_BOP_ID = BOP.SUB_BOP_ID)
  where RD.RECEIPT_DATE = @data_date
  and BOP.SUB_BOP_CODE = 'PT'
  if (@@rowcount = 0)
  begin
    break
  end

  delete from PM_RECEIPT_PREPAID where RECEIPT_ID = @receipt_id and RECEIPT_DATE = @data_date
  delete from PM_RECEIPT_DTL_PREPAID where RECEIPT_DTL_ID = @receipt_dtl_id and RECEIPT_DATE = @data_date
  delete from PM_RECEIPT_DTL where RECEIPT_ID = @receipt_id and RECEIPT_DATE = @data_date
  delete from PM_RECEIPT where RECEIPT_ID = @receipt_id and RECEIPT_DATE = @data_date

end

go

