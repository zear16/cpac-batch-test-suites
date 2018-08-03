use PMDB

go

set nocount on

delete from PM_ADJUST_BOS
where TRANSACTION_ID in ('201607280000001')
and MOBILE_NO = '0854000673'
and OPERATION_DATE = '20160615'

go

 
