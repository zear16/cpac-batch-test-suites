use PMDB

go

set nocount on

declare @trans_date    date
declare @category_code unsigned bigint
declare @bank_code     unsigned bigint
declare @mobile_no     varchar(20)

select @trans_date = '20160615'
, @mobile_no = '0811097495'

select @bank_code = BANK_CODE from PM_BANK where BANK_ABBR = 'GGP'

select @category_code = CATEGORY_CODE
from PM_PAYMENT_CATEGORY where CATEGORY_ABBR = 'MP'

delete PM_RECEIPT_PAYMENT
from PM_RECEIPT R
inner join PM_RECEIPT_PAYMENT P on (R.RECEIPT_ID = P.RECEIPT_ID and R.RECEIPT_DATE = P.RECEIPT_DATE)
where R.RECEIPT_DATE = @trans_date
and R.CATEGORY_CODE = @category_code
and R.BANK_CODE = @bank_code
and R.MOBILE_NO = @mobile_no

delete PM_RECEIPT_DTL
from PM_RECEIPT R
inner join PM_RECEIPT_DTL P on (R.RECEIPT_ID = P.RECEIPT_ID and R.RECEIPT_DATE = P.RECEIPT_DATE)
where R.RECEIPT_DATE = @trans_date
and R.CATEGORY_CODE = @category_code
and R.BANK_CODE = @bank_code
and R.MOBILE_NO = @mobile_no

delete PM_RECEIPT_ADDR
from PM_RECEIPT R
inner join PM_RECEIPT_ADDR P on (R.RECEIPT_ID = P.RECEIPT_ID and R.RECEIPT_DATE = P.RECEIPT_DATE)
where R.RECEIPT_DATE = @trans_date
and R.CATEGORY_CODE = @category_code
and R.BANK_CODE = @bank_code
and R.MOBILE_NO = @mobile_no

delete from PM_RECEIPT
where RECEIPT_DATE = @trans_date
and CATEGORY_CODE = @category_code
and BANK_CODE = @bank_code
and MOBILE_NO = @mobile_no

go


