use PMDB

go

set nocount on

declare @trans_date date

select @trans_date = '20160616'

delete PM_CREDIT_NOTE_DTL
from PM_CREDIT_NOTE C
inner join PM_CREDIT_NOTE_DTL CD on (C.CN_ID = CD.CN_ID and C.CN_DATE = CD.CN_DATE)
where C.CN_NO like 'ForUnitTestDCBPurchase%'
and C.CN_DATE = @trans_date

delete from PM_CREDIT_NOTE
where CN_NO like 'ForUnitTestDCBPurchase%'
and CN_DATE = @trans_date

go


