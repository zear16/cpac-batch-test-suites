use PMDB

go

set nocount on

declare @adjust_id unsigned bigint
declare @so_nbr    varchar(64)
declare @billing   varchar(4)

select @billing = 'INS'

select @so_nbr = 'Unit Test Adjust INS Reconcile Amount'

select @adjust_id = ADJUST_ID from PM_ADJUST_TRANSACTION where SO_NBR = @so_nbr
if (@@rowcount = 0)
begin

  insert into PM_ADJUST_TRANSACTION
  (SO_NBR, MOBILE_NO, ADJUST_AMT, ADJUST_VALIDITY, ADJUST_STATUS, BILLING_SYSTEM
  , ADJUST_DTM
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@so_nbr, '0811097495', 938, null, 'SC', @billing
  , '20160615'
  , 'unit', '20160615', 'unit', '20160615')

end


select @so_nbr = 'Unit Test Adjust INS Reconcile Validity'

select @adjust_id = ADJUST_ID from PM_ADJUST_TRANSACTION where SO_NBR = @so_nbr
if (@@rowcount = 0)
begin

  insert into PM_ADJUST_TRANSACTION
  (SO_NBR, MOBILE_NO, ADJUST_AMT, ADJUST_VALIDITY, ADJUST_STATUS, BILLING_SYSTEM
  , ADJUST_DTM
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@so_nbr, '0811097495', null, 25, 'SC', @billing
  , '20160615'
  , 'unit', '20160615', 'unit', '20160615')

end

select @so_nbr = 'Unit Test Adjust BOS Reconcile Both'

select @adjust_id = ADJUST_ID from PM_ADJUST_TRANSACTION where SO_NBR = @so_nbr
if (@@rowcount = 0)
begin

  insert into PM_ADJUST_TRANSACTION
  (SO_NBR, MOBILE_NO, ADJUST_AMT, ADJUST_VALIDITY, ADJUST_STATUS, BILLING_SYSTEM
  , ADJUST_DTM
  , CREATED_BY, CREATED, LAST_UPD_BY, LAST_UPD)
  values
  (@so_nbr, '0811097495', 938, 25, 'SC', @billing
  , '20160615'
  , 'unit', '20160615', 'unit', '20160615')

end

go

