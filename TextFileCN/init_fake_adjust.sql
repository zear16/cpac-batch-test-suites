use PMDB

go

set nocount on

declare @adjust_id unsigned bigint
declare @so_nbr varchar(64)

select @so_nbr = 'Unit Test Text File CN Reconcile'

select @adjust_id = ADJUST_ID from PM_ADJUST_TRANSACTION where SO_NBR = @so_nbr
if (@@rowcount = 0)
begin

  insert into PM_ADJUST_TRANSACTION
  (SO_NBR, MOBILE_NO, ADJUST_AMT, ADJUST_VALIDITY, ADJUST_STATUS
  , ADJUST_DTM, ADJUST_DATE, CN_NO, BILLING_SYSTEM, GEN_CN_BOO
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@so_nbr, '0901000001', -100, null, 'SC'
  , '20160615', '20160615', 'XXX', 'RTBS', 'Y'
  , 'unit', '20160615', 'unit', '20160615')

  select @adjust_id = @@identity

end

print '%1!', @adjust_id


go

