use PMDB

go

set nocount on

declare @company_id unsigned bigint

select @company_id = COMPANY_ID from PM_COMPANY where COMPANY_ABBR = 'AMP'

delete from PM_ADJUST_BOS
where TRANSACTION_ID = '00201606160901000009'
and MOBILE_NO = '0901000009'
and OPERATION_DTM = '20160616'

go

 
