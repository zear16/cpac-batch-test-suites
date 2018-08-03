use PMDB

go

set nocount on

declare @trans_date    date
declare @category_code unsigned bigint
declare @bank_code     unsigned bigint
declare @mobile_no     varchar(20)
declare @receipt_id    unsigned bigint
declare @loop          int

select @trans_date = '20160615'
, @mobile_no = '0817053436'
, @loop = 1

--select @bank_code = BANK_CODE from PM_BANK where BANK_ABBR = 'MPM'

--select @category_code = CATEGORY_CODE
--from PM_PAYMENT_CATEGORY where CATEGORY_ABBR = 'MP'

while (@loop = 1)
begin

  select @loop = 0

  select top 1 @receipt_id = R.RECEIPT_ID
  from PM_RECEIPT R
  inner join PM_RECEIPT_DTL RD on (R.RECEIPT_ID = RD.RECEIPT_ID and R.RECEIPT_DATE = RD.RECEIPT_DATE)
  inner join PM_SUB_BUSINESS_OF_PAYMENT BOP on (RD.SUB_BOP_ID = BOP.SUB_BOP_ID)
  where R.RECEIPT_DATE = @trans_date
  and R.MOBILE_NO = @mobile_no
  and BOP.SUB_BOP_CODE in ('DD', 'DV')
  if (@@rowcount != 0)
  begin

    select @loop = 1

    delete PM_RECEIPT_PAYMENT
    from PM_RECEIPT R
    inner join PM_RECEIPT_PAYMENT P on (R.RECEIPT_ID = P.RECEIPT_ID and R.RECEIPT_DATE = P.RECEIPT_DATE)
    where R.RECEIPT_ID = @receipt_id
    and R.RECEIPT_DATE = @trans_date

    delete PM_RECEIPT_DTL
    from PM_RECEIPT R
    inner join PM_RECEIPT_DTL P on (R.RECEIPT_ID = P.RECEIPT_ID and R.RECEIPT_DATE = P.RECEIPT_DATE)
    where R.RECEIPT_ID = @receipt_id
    and R.RECEIPT_DATE = @trans_date

    delete PM_RECEIPT_ADDR
    from PM_RECEIPT R
    inner join PM_RECEIPT_ADDR P on (R.RECEIPT_ID = P.RECEIPT_ID and R.RECEIPT_DATE = P.RECEIPT_DATE)
    where R.RECEIPT_DATE = @trans_date
    and R.RECEIPT_ID = @receipt_id

    delete from PM_RECEIPT
    where RECEIPT_DATE = @trans_date
    and RECEIPT_ID = @receipt_id

  end

end

--delete PM_RECEIPT_PAYMENT
--from PM_RECEIPT R
--inner join PM_RECEIPT_DTL P on (R.RECEIPT_ID = P.RECEIPT_ID and R.RECEIPT_DATE = P.RECEIPT_DATE)
--inner join PM_SUB_BUSINESS_OF_PAYMENT BOP on (RD.SUB_BOP_ID = BOP.SUB_BOP_ID)
--inner join PM_RECEIPT_PAYMENT P on (R.RECEIPT_ID = P.RECEIPT_ID and R.RECEIPT_DATE = P.RECEIPT_DATE)
--where R.RECEIPT_DATE = @trans_date
--and R.CATEGORY_CODE = @category_code
--and R.BANK_CODE = @bank_code
--and R.MOBILE_NO = @mobile_no
--and BOP.SUB_BOP_CODE in ('DD', 'DV')

--delete PM_RECEIPT_DTL
--from PM_RECEIPT R
--inner join PM_RECEIPT_DTL P on (R.RECEIPT_ID = P.RECEIPT_ID and R.RECEIPT_DATE = P.RECEIPT_DATE)
--where R.RECEIPT_DATE = @trans_date
--and R.CATEGORY_CODE = @category_code
--and R.BANK_CODE = @bank_code
--and R.MOBILE_NO = @mobile_no

--delete PM_RECEIPT_ADDR
--from PM_RECEIPT R
--inner join PM_RECEIPT_ADDR P on (R.RECEIPT_ID = P.RECEIPT_ID and R.RECEIPT_DATE = P.RECEIPT_DATE)
--where R.RECEIPT_DATE = @trans_date
--and R.CATEGORY_CODE = @category_code
--and R.BANK_CODE = @bank_code
--and R.MOBILE_NO = @mobile_no

--delete from PM_RECEIPT
--where RECEIPT_DATE = @trans_date
--and CATEGORY_CODE = @category_code
--and BANK_CODE = @bank_code
--and MOBILE_NO = @mobile_no

go


