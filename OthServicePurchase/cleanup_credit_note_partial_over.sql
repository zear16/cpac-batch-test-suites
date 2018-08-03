use PMDB

go

set nocount on

declare @trans_date date
declare @backward   int

select @backward = convert(int,FIELD1_VALUE)
from PM_SYSTEM_ATTRIBUTE_DTL
where ATTRIBUTE_CODE = 'CPAC_PARAM'
and DB_VALUE = 'QUERY_RECHARGE_PERIOD'

select @trans_date = dateadd(mm, -@backward, getdate())

delete PM_CREDIT_NOTE_DTL
from PM_CREDIT_NOTE C
inner join PM_CREDIT_NOTE_DTL CD on (C.CN_ID = CD.CN_ID and C.CN_DATE = CD.CN_DATE)
where C.CN_NO like 'ForUnitTestDCBPurchase%'
and C.CN_DATE = @trans_date

delete from PM_CREDIT_NOTE
where CN_NO like 'ForUnitTestDCBPurchase%'
and CN_DATE = @trans_date

go


