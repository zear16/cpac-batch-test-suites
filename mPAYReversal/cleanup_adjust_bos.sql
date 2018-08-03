use PMDB

go

set nocount on

declare @company_id unsigned bigint
declare @mobile_no varchar(20)

select @mobile_no = '0910021160'

select @company_id = COMPANY_ID from PM_COMPANY where COMPANY_ABBR = 'AWN'

delete from PM_ADJUST_BOS
where TRANSACTION_ID = '00201606160901000009'
and MOBILE_NO = @mobile_no
and OPERATION_DATE = '20160615'

go

 
