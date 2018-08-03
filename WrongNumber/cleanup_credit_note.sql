use PMDB

go

delete from PM_CREDIT_NOTE
where CN_NO like 'ForUnitTestWrongNumber%'
and CN_DATE = '20160615'

go


